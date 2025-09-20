#!/usr/bin/env bash
# $HOME/scripts/vm-deploy-hook.sh
set -euo pipefail

# Load environment variables from ansible.env if present (KEY=VALUE lines)
if [ -f "$HOME/scripts/ansible.env" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$HOME/scripts/ansible.env"
  set +a
fi

# Get VMID from input parameter
VMID="${1:-}"
if [ -z "$VMID" ]; then
  echo "Usage: $0 <VMID>" >&2
  exit 2
fi

# Check if VMID exists for QEMU or PCT
if qm status "$VMID" &> /dev/null; then
    TYPE="qemu"
elif pct status "$VMID" &> /dev/null; then
    TYPE="lxc"
else
    echo "VMID $VMID does not exist."
    exit 1
fi

# Echo the type of VM
echo "VMID $VMID exists as a $TYPE."

# Get the IP address of the virtual machine or container, excluding the loopback address and non-bridge addresses
if [ "$TYPE" = "lxc" ]; then
    IP=$(pct exec "$VMID" -- ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
    # Check if SSH key already exists in the container
    if ! pct exec "$VMID" -- grep -q "$(cat "$SSH_KEY_PATH")" "/home/$SSH_USER/.ssh/authorized_keys"; then
        # Add SSH key to the container
        pct exec "$VMID" -- mkdir -p "/home/$SSH_USER/.ssh"
        pct exec "$VMID" -- bash -c "echo '$(cat "$SSH_KEY_PATH")' >> /home/$SSH_USER/.ssh/authorized_keys"
        pct exec "$VMID" -- chown -R "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.ssh"
    fi
else
    IP=$(qm guest exec "$VMID" ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
    # Check if SSH key already exists in the virtual machine
    if ! qm guest exec "$VMID" grep -q "$(cat "$SSH_KEY_PATH")" "/home/$SSH_USER/.ssh/authorized_keys"; then
        # Add SSH key to the virtual machine
        qm set "$VMID" --sshkey "$SSH_KEY_PATH"
    fi
fi

# Echo the IP address
echo "IP address for VMID $VMID is $IP."

# Send a POST request to the Ansible API server
curl -X POST "$ANSIBLE_API_URL" \
     -H "Content-Type: application/json" \
     -d "{\"vmid\": \"$VMID\", \"ip\": \"$IP\", \"user\": \"$SSH_USER\"}"
