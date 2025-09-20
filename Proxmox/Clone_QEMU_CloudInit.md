# ☁️ QEMU Cloud-Init Templates for Proxmox

This guide explains how to create and manage VM templates with Cloud-Init in Proxmox VE.

## 📋 Table of Contents

- [Overview](#overview)
- [Creating a Cloud-Init Template](#creating-a-cloud-init-template)
- [Cloning from Template](#cloning-from-template)
- [Cloud-Init Configuration Options](#cloud-init-configuration-options)
- [Automation Scripts](#automation-scripts)
- [Troubleshooting](#troubleshooting)

## Overview

Cloud-Init is the industry standard for early VM initialization. Using Cloud-Init with Proxmox allows you to:

- Create template VMs once and deploy many customized instances
- Automate network configuration
- Set hostnames, SSH keys, and user passwords on first boot
- Run custom initialization scripts

## Creating a Cloud-Init Template

### Step 1: Download a Cloud-Init Ready Image

```bash
# Create a directory for the image
mkdir -p /var/lib/vz/template/iso

# Download Ubuntu Cloud Image (example)
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

### Step 2: Create a New VM

```bash
# Create a VM with no ISO attached
qm create 9000 --name ubuntu-cloud-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# Import the disk
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm

# Configure the disk
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0

# Add Cloud-Init CDROM drive
qm set 9000 --ide2 local-lvm:cloudinit

# Set boot disk and enable serial console
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0

# Convert to template
qm template 9000
```

## Cloning from Template

### Quick Clone Command

```bash
qm clone 9000 123 --name my-cloud-vm
```

### Setting Cloud-Init Parameters

```bash
# Set Cloud-Init parameters
qm set 123 --ciuser admin
qm set 123 --cipassword "your-password"
qm set 123 --sshkeys /path/to/your/public/key.pub
qm set 123 --ipconfig0 ip=dhcp
# OR for static IP
qm set 123 --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1

# Start the VM
qm start 123
```

## Cloud-Init Configuration Options

| Parameter | Description | Example |
|-----------|-------------|---------|
| ciuser    | Username to create | `--ciuser admin` |
| cipassword | Password for the user | `--cipassword "secure-password"` |
| sshkeys | Path to SSH public key(s) | `--sshkeys /root/.ssh/id_rsa.pub` |
| ipconfig0 | Network configuration for first interface | `--ipconfig0 ip=dhcp` |
| ipconfig1 | Network config for second interface | `--ipconfig1 ip=10.10.10.10/24,gw=10.10.10.1` |
| nameserver | DNS servers | `--nameserver 1.1.1.1` |
| searchdomain | DNS search domain | `--searchdomain example.com` |

## Automation Scripts

You can automate template creation and deployment with the following scripts:

1. **Template Creation Script**

```bash
#!/bin/bash
# create-template.sh
# Usage: ./create-template.sh TEMPLATE_ID IMAGE_URL

TEMPLATE_ID=$1
IMAGE_URL=$2
IMAGE_NAME=$(basename $IMAGE_URL)

# Download image if it doesn't exist
if [ ! -f "/var/lib/vz/template/iso/$IMAGE_NAME" ]; then
  wget -P /var/lib/vz/template/iso/ $IMAGE_URL
fi

# Create and configure VM
qm create $TEMPLATE_ID --name cloud-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk $TEMPLATE_ID /var/lib/vz/template/iso/$IMAGE_NAME local-lvm
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --ide2 local-lvm:cloudinit
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm template $TEMPLATE_ID

echo "Template $TEMPLATE_ID created successfully."
```

2. **Deployment Script**

```bash
#!/bin/bash
# deploy-vm.sh
# Usage: ./deploy-vm.sh TEMPLATE_ID NEW_ID NAME IP SSH_KEY

TEMPLATE_ID=$1
NEW_ID=$2
NAME=$3
IP=$4
SSH_KEY=$5

qm clone $TEMPLATE_ID $NEW_ID --name $NAME
qm set $NEW_ID --ciuser admin
qm set $NEW_ID --sshkeys $SSH_KEY
qm set $NEW_ID --ipconfig0 ip=$IP/24,gw=192.168.1.1
qm start $NEW_ID

echo "VM $NAME (ID: $NEW_ID) deployed successfully."
```

## Troubleshooting

### Common Issues and Solutions

1. **Cloud-Init Not Running on Boot**
   - Check that the Cloud-Init drive is properly attached
   - Verify the image supports Cloud-Init

2. **Network Not Configured**
   - Check bridge configuration on the host
   - Verify that DHCP is available if using dynamic IP

3. **Password/SSH Key Not Working**
   - Ensure the SSH key format is correct
   - Check for special characters in passwords that might need escaping

4. **VM Can't Reach Network After Configuration**
   - Verify gateway configuration
   - Check network bridge setup on the Proxmox host

### Logs and Debugging

Cloud-Init logs are available in the VM at:
- `/var/log/cloud-init.log`
- `/var/log/cloud-init-output.log`

To access these logs without SSH:
```bash
qm guest cmd VMID cat /var/log/cloud-init.log
```

## Additional Resources

- [Official Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Proxmox Wiki: Cloud-Init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
- [Proxmox API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/)