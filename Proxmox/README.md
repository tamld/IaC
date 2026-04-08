# 🖥️ Proxmox VE — Automation Scripts

Shell scripts for managing Proxmox VE: LXC containers, virtual machines, backups, and security hardening.

## Scripts

| Script | Description |
|--------|-------------|
| `clone_pct.sh` | Clone an LXC container from a template |
| `destroy_pct.sh` | Safely destroy an LXC container |
| `proxmox_backup.sh` | Automated vzdump backup with retention |
| `restore_pct.sh` | Restore an LXC container from backup |
| `clean_old_vzdump.sh` | Remove old backups by retention policy |
| `ssh_hardening.sh` | Apply SSH security best practices to the host |
| `set_timezone.sh` | Set system timezone on Proxmox host |
| `show_ip_pct.sh` | List IP addresses of all running containers |
| `vm-deploy-hook.sh` | Post-clone VM deployment hook |
| `deploy_teleport_agent.sh` | Bootstrap a Teleport node agent on new containers |

## Usage

```bash
cd Proxmox/scripts
chmod +x *.sh
./clone_pct.sh --help   # shows usage for each script
```

## Sub-modules

- [`terraform/`](terraform/) — Terraform provider configuration for Proxmox VE

## Notes

- Scripts use `common.sh` for shared functions (logging, color output)
- All scripts are idempotent — safe to run multiple times
- Tested on Proxmox VE 7.x and 8.x