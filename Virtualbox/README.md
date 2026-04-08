# 📦 VirtualBox — Local Development Environments

Scripts and configurations for VirtualBox-based local development using Vagrant.

## Contents

| File | Description |
|------|-------------|
| `restoreVM.sh` | Restore a VirtualBox VM from a `.vbox` or snapshot |
| `Vagrantfile` (if present) | Vagrant configuration for automated VM provisioning |

## Prerequisites

- [VirtualBox](https://www.virtualbox.org/) 6.x or 7.x
- [Vagrant](https://www.vagrantup.com/) (optional, for `Vagrantfile` usage)

## Restore a VM

```bash
chmod +x restoreVM.sh
./restoreVM.sh <vm-name>   # restores from latest snapshot or OVA
```

## With Vagrant

```bash
vagrant up       # Create and provision VM
vagrant ssh      # SSH into the VM
vagrant halt     # Stop the VM
vagrant destroy  # Remove the VM completely
```

## Notes

- VirtualBox is best for local testing; use Proxmox or VMware for production
- Use `VBoxManage` CLI for scripted snapshot management
- Vagrant boxes sourced from [app.vagrantup.com/boxes/search](https://app.vagrantup.com/boxes/search)