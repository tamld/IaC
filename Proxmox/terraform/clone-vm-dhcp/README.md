# Deploy a VM in Proxmox with Terraform (DHCP example)

## 1. Overview
This document describes how to create a Proxmox VM from a prebuilt template using Terraform.

- Download a base Ubuntu cloud image and create a template VM.
- Prebuild template with hardware configuration, qemu-guest-agent, and required packages.
- Create Terraform files (`main.tf`, `var.tf`, `terraform.tfvars`) and run Terraform to create VMs from the template.

### 1.1 Create template

### 1.2 Server Proxmox Settings

Install Terraform and choose an authentication method (API token recommended).

### 1.3 Terraform init new VM

- Run `terraform init` to initialize the working directory and providers.
- Run `terraform plan` to inspect planned changes.

## 2. Installation

### 2.1 Create template (short checklist)
- Create symlinks for ISO and CT template directories (optional):

```bash
ln -s /var/lib/vz/template/iso/ liso
ln -s /var/lib/vz/template/cache/ lct
```

#### Download a base Ubuntu cloud image

```bash
# Download Ubuntu cloud images (examples)
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

#### Install libguestfs-tools

```bash
apt update -y && apt install libguestfs-tools -y
```

#### Add qemu-guest-agent and other packages

```bash
# Example: add packages to a cloud image
virt-customize -a focal-server-cloudimg-amd64.img --install openssh-server,wget,git,curl,zsh,net-tools,nano
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent
```

#### List available storages (example output omitted)

> Note: example lsblk and pvesm output have been removed to avoid accidental inclusion of host-specific data. Use the commands below to view on your host:

```bash
lsblk
pvesm status
```

#### Create a Proxmox VM using the image

```bash
qm create 9000 --name "ubuntu-2004-cloudinit-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr1
qm importdisk 9000 focal-server-cloudimg-amd64.img zfs
qm set 9000 --scsihw virtio-scsi-pci --scsi0 zfs:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 zfs:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
```

### 2.2 Server Proxmox Settings (links)
- Terraform CLI install: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- Creating the Proxmox user & role for Terraform: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform
- Telmate provider installation guide: https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/installation.md

### 2.3 Terraform examples

Initialize a `main.tf` and `var.tf` in the terraform folder.

- Example `main.tf` (template location in repo): `Proxmox/terraform/clone-new-vm/main.tf` (added to repo as a minimal template).

### 2.4 terraform.tfvars

Create `terraform.tfvars` with sensitive values locally and do not commit them.

```hcl
proxmox_host = "YOUR_PROMOX_HOST"
template_name = "YOUR_IMAGE_TEMPLATE"
token_id = "YOUR_TOKEN_ID"
token_secret = "YOUR_TOKEN_SECRET"
pm_api_url = "https://YOUR_IP/DOMAIN:8006/api2/json"
vm_name = "YOUR_VM_NAME"
vm_os = "YOUR_VM_OS"
username = "YOUR_USERNAME"
password = "YOUR_PASSWORD"
ssh_key = "YOUR_PUBLIC_KEYS"
```

## 3. Terraform workflow

Run `terraform init`, `terraform plan`, then `terraform apply` when ready. See the Telmate provider docs for provider-specific options.

---
Edits: cleaned terminal prompt/output artifacts, normalized code blocks, and added link to minimal `clone-new-vm/main.tf` template in this branch.
