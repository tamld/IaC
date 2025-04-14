# 🖥️ Proxmox Infrastructure as Code

This directory contains Infrastructure as Code solutions for Proxmox Virtual Environment, including automation scripts, Terraform configurations, and templates.

## 📚 Table of Contents

| Component | Description |
|-----------|-------------|
| [📜 Bash Scripts](./bash/) | Automation scripts for Proxmox management |
| [🔄 Terraform](./terraform/) | Terraform modules for Proxmox infrastructure |
| [☁️ Cloud-Init](./Clone_QEMU_CloudInit.md) | Cloud-init templates for VM initialization |

## 🚀 Features

### 📜 Bash Scripts

Ready-to-use scripts for common Proxmox operations:

- **[clone-pct.sh](./bash/clone-pct.sh)**: Clones Proxmox containers with customizable options
  - Supports full and minimal installation modes
  - Automatically copies SSH keys
  - Handles hostname configuration
  - Installs pre-defined packages

- **[destroy-VM-CT.sh](./bash/destroy-VM-CT.sh)** & **[destroy_pct.sh](./bash/destroy_pct.sh)**: Safely remove VMs and containers

- **[backup-to-online-drive](./bash/backup-to-online-drive/)**: Backup solutions for Proxmox

### 🔄 Terraform Configurations

Infrastructure as Code for Proxmox using Terraform:

- VM and container provisioning
- Network configuration
- Storage management
- Resource allocation

### ☁️ Cloud-Init Templates

- [QEMU Cloud-Init Templates](./Clone_QEMU_CloudInit.md): Templates for rapid VM deployment

## 📋 Usage Guide

### Container Management Scripts

#### Clone Containers

```bash
# Interactive mode - prompts for hostname and installation options
./clone-pct.sh

# Non-interactive mode with full app installation
./clone-pct.sh new-container-hostname --full

# Non-interactive mode with minimal installation
./clone-pct.sh new-container-hostname --minimal
```

#### Destroy Containers/VMs

```bash
# Remove a container
./destroy_pct.sh CONTAINER_ID

# Remove a VM or container
./destroy-VM-CT.sh VM_OR_CONTAINER_ID
```

### Terraform Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan -var-file="vars.tfvars"

# Apply configuration
terraform apply -var-file="vars.tfvars"
```

## 🔧 Prerequisites

- Proxmox VE 6.x or newer
- SSH access to Proxmox host
- For Terraform: Terraform 0.14+ and Proxmox provider
- For backups: rclone configured with cloud storage

## 📝 Best Practices

1. **Template Management**: Create and maintain standardized templates
2. **Automation**: Use scripts for repetitive tasks
3. **Version Control**: Keep infrastructure configurations in Git
4. **Documentation**: Maintain clear documentation for all custom scripts
5. **Idempotency**: Ensure scripts can be run multiple times without issues

## 🔗 Related Resources

- [Official Proxmox Documentation](https://pve.proxmox.com/pve-docs/)
- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.