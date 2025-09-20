#!/usr/bin/env bash
set -e

########################################
# Function: exec_in_container
########################################
exec_in_container() {
    local CTID="$1"
    local CMD="$2"
    timeout 300 pct exec "$CTID" -- bash -c "$CMD"
}

########################################
# Function: update_or_append
########################################
update_or_append() {
    local CTID="$1"
    local KEY="$2"
    local VALUE="$3"
    local FILE="/etc/ssh/sshd_config"

    exec_in_container "$CTID" "
        grep -Eq '^[#]*\\s*${KEY}' $FILE && \
            sed -i 's|^[#]*\\s*${KEY}.*|${KEY} ${VALUE}|' $FILE || \
            echo '${KEY} ${VALUE}' >> $FILE
    "
}

########################################
# Function: copy_authorized_keys_append (default)
# Description: Append public key(s) from host into container's authorized_keys
########################################
copy_authorized_keys_append() {
    local CTID="$1"
    local USER="${2:-root}"
    local HOST_KEY_FILE="/root/.ssh/authorized_keys"
    local CT_KEY_PATH="/${USER}/.ssh/authorized_keys"

    if [[ ! -f "$HOST_KEY_FILE" ]]; then
        echo "[WARN] No authorized_keys found on host at $HOST_KEY_FILE"
        return
    fi

    echo "[INFO] Appending authorized_keys to CTID $CTID user $USER..."

    # Push host key file to a temporary file in the container
    pct push "$CTID" "$HOST_KEY_FILE" "/tmp/host_keys.tmp"

    exec_in_container "$CTID" "
        mkdir -p /${USER}/.ssh && \
        touch ${CT_KEY_PATH} && \
        cat /tmp/host_keys.tmp >> ${CT_KEY_PATH} && \
        sort -u ${CT_KEY_PATH} -o ${CT_KEY_PATH} && \
        chmod 600 ${CT_KEY_PATH} && \
        rm -f /tmp/host_keys.tmp
    "

    echo "[INFO] Key(s) appended to CTID $CTID for user $USER"
}

########################################
# Function: copy_authorized_keys_replace
# Description: Replace entire authorized_keys file with host's copy
########################################
copy_authorized_keys_replace() {
    local CTID="$1"
    local USER="${2:-root}"
    local HOST_KEY_FILE="/root/.ssh/authorized_keys"
    local CT_KEY_PATH="/${USER}/.ssh/authorized_keys"

    if [[ ! -f "$HOST_KEY_FILE" ]]; then
        echo "[WARN] No authorized_keys found on host at $HOST_KEY_FILE"
        return
    fi

    echo "[INFO] Replacing authorized_keys in CTID $CTID user $USER..."

    exec_in_container "$CTID" "
        mkdir -p /${USER}/.ssh && \
        chmod 700 /${USER}/.ssh && \
        touch ${CT_KEY_PATH} && \
        chmod 600 ${CT_KEY_PATH}
    "

    pct push "$CTID" "$HOST_KEY_FILE" "$CT_KEY_PATH" --perms 600

    echo "[INFO] authorized_keys replaced in CTID $CTID for user $USER"
}

########################################
# Function: set_allow_users (optional)
########################################
set_allow_users() {
    local CTID="$1"
    local USERS="$2"
    update_or_append "$CTID" "AllowUsers" "$USERS"
    echo "[INFO] Set AllowUsers to: $USERS"
}

########################################
# Function: harden_ssh_config
########################################
harden_ssh_config() {
    local CTID="$1"
    local CONFIG="/etc/ssh/sshd_config"
    local BACKUP="/etc/ssh/sshd_config.bak"

    local HOSTNAME
    HOSTNAME=$(pct config "$CTID" | awk '/^hostname:/ {print $2}')

    echo "[INFO] Hardening SSH config for CTID $CTID ($HOSTNAME)..."

    # Install openssh-server if not present
    exec_in_container "$CTID" "
        dpkg -s openssh-server &>/dev/null || (apt-get update && apt-get install -y openssh-server)
    "

    # Backup current SSH config
    exec_in_container "$CTID" "cp $CONFIG $BACKUP"

    # SSH configuration hardening
    update_or_append "$CTID" "PasswordAuthentication" "no"           # Disable password login
    update_or_append "$CTID" "PermitRootLogin" "prohibit-password"   # Disallow root password login
    update_or_append "$CTID" "PubkeyAuthentication" "yes"            # Enable SSH key login
    update_or_append "$CTID" "MaxAuthTries" "3"                       # Limit auth attempts
    update_or_append "$CTID" "LoginGraceTime" "20"                    # Set short login grace time
    update_or_append "$CTID" "ClientAliveInterval" "300"            # Keepalive interval (optional)
    update_or_append "$CTID" "ClientAliveCountMax" "2"              # Max missed keepalives (optional)
    update_or_append "$CTID" "UseDNS" "no"                          # Disable DNS lookups (optional)
    update_or_append "$CTID" "X11Forwarding" "no"                   # Disable X11 forwarding (optional)
    update_or_append "$CTID" "PermitEmptyPasswords" "no"             # Disallow empty passwords
    # update_or_append "$CTID" "AllowTcpForwarding" "no"              # Disable TCP forwarding (optional)
    # update_or_append "$CTID" "MaxSessions" "2"                      # Limit sessions (optional)
    update_or_append "$CTID" "LogLevel" "VERBOSE"                    # Increase log verbosity


    # Validate SSH config before restarting
    exec_in_container "$CTID" "
        sshd -t && (systemctl restart ssh || service ssh restart)
    "

    # Deploy public key(s) - using append method by default
    #copy_authorized_keys_replace "$CTID" "root"
    copy_authorized_keys_append "$CTID" "root"

    echo "[SUCCESS] SSH hardened for CTID $CTID ($HOSTNAME)"
}

########################################
# Function: list_pcts
########################################
list_pcts() {
    echo "Available Containers:"
    printf "%-8s %-20s %-10s\n" "VMID" "Hostname" "Status"

    pct list | tail -n +2 | while read -r line; do
        VMID=$(echo "$line" | awk '{print $1}')
        STATUS=$(echo "$line" | awk '{print $2}')
        HOSTNAME=$(pct config "$VMID" | awk '/^hostname:/ {print $2}')
        printf "%-8s %-20s %-10s\n" "$VMID" "$HOSTNAME" "$STATUS"
    done
}

########################################
# Function: main
########################################
main() {
    # list_pcts
    echo "Available Containers:"
    pct list
    echo ""

read -r -p "Enter one or more VMIDs to harden (space-separated, or 'all'): " -a INPUTS
    echo ""

    if [[ "${INPUTS[0]}" == "all" ]]; then
        # Get all existing CTIDs from pct list (excluding header line)
        mapfile -t VMIDS < <(pct list | awk 'NR>1 {print $1}')
    else
        VMIDS=("${INPUTS[@]}")
    fi

    for CTID in "${VMIDS[@]}"; do
        if ! pct status "$CTID" &>/dev/null; then
            echo "[ERROR] CTID $CTID does not exist. Skipping."
            continue
        fi

        if ! pct status "$CTID" | grep -q running; then
            echo "[INFO] Starting container $CTID..."
            pct start "$CTID"
            sleep 5
        fi

        if harden_ssh_config "$CTID"; then
            echo "[DONE] CTID $CTID SSH hardening completed."
        else
            echo "[FAIL] CTID $CTID SSH hardening failed."
        fi
        echo "--------------------------------------"
    done
}

main
