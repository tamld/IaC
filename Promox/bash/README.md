# 📜 Proxmox Bash Scripts

This directory contains bash scripts for automating common Proxmox operations.

## 🛠️ Available Scripts

| Script | Purpose |
|--------|---------|
| [clone-pct.sh](./clone-pct.sh) | Clone Proxmox containers with customizable options |
| [destroy-VM-CT.sh](./destroy-VM-CT.sh) | Remove VMs or containers |
| [destroy_pct.sh](./destroy_pct.sh) | Remove containers (alternative implementation) |
| [backup-to-online-drive/](./backup-to-online-drive/) | Backup scripts for Proxmox to cloud storage |

## 📋 Scripts Details

### 📄 clone-pct.sh

A powerful script for cloning Proxmox containers with customization options.

#### Features:

- Creates new containers from a template
- Sets custom hostnames
- Configures SSH key access
- Installs software packages based on selected profile:
  - **Full mode**: Complete server setup with all tools
  - **Minimal mode**: Essential tools only (zsh, tmux, Docker)

#### Usage:

```bash
# Interactive mode (with prompts)
./clone-pct.sh

# Non-interactive with full installation
./clone-pct.sh my-new-server --full

# Non-interactive with minimal installation
./clone-pct.sh my-new-server --minimal
```

### 📄 destroy-VM-CT.sh

Safely removes VMs or containers from Proxmox.

#### Features:

- Stops the VM/container before deletion
- Confirms removal to prevent accidents
- Works with both VMs and containers

#### Usage:

```bash
./destroy-VM-CT.sh 123
```

### 📄 destroy_pct.sh

Alternative container removal script.

#### Features:

- Focused specifically on container (PCT) removal
- Simple interface for quick operations

#### Usage:

```bash
./destroy_pct.sh 123
```

### 📁 backup-to-online-drive/

Scripts for backing up Proxmox data to cloud storage services.

#### Features:

- Scheduled backups to cloud storage
- Retention policy management
- Secure transfer of backups

## 💡 Best Practices

1. **Review Before Running**: Always review script actions before execution
2. **Regular Testing**: Test scripts in a non-production environment
3. **Keep Updated**: Update scripts to match your current Proxmox version
4. **Customize Templates**: Modify the template ID in clone-pct.sh to match your environment
5. **Backup First**: Always have backups before mass-deleting VMs/containers

## 🔒 Security Notes

- Scripts may require root access on the Proxmox host
- Be careful with scripts that automatically install software
- Verify URLs used in wget commands for security