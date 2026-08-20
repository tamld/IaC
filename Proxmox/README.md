# 🖥️ Proxmox VE — Automation, Containerization & Resilience

Shell scripts, systemd templates, and Terraform blueprints for managing Proxmox VE 8.x & 9.x: LXC containers, daemonless Podman, automated backups, and circuit breaker resilience.

## 📁 Sub-modules & Blueprints

| Blueprint / Module | Description | Lifecycle |
|:---|:---|:---:|
| 🦭 [`podman-lxc/`](podman-lxc/) | Daemonless Podman container provisioning on Unprivileged LXC | 🟢 `[ACTIVE PROD]` |
| ⚡ [`circuit-breaker/`](circuit-breaker/) | Bounded Self-Healing & Systemd Circuit Breaker notification | 🟢 `[ACTIVE PROD]` |
| 💾 [`pbs-backup/`](pbs-backup/) | Proxmox Backup Server (PBS) client chunk deduplication (3-2-1) | 🟢 `[ACTIVE PROD]` |
| 🌐 [`network-mikrotik/`](network-mikrotik/) | MikroTik RouterOS 3-VLAN micro-segmentation & split-horizon DNS | 🟢 `[ACTIVE PROD]` |
| 🗄️ [`sqlite-maintenance/`](sqlite-maintenance/) | Non-blocking live SQLite database VACUUM INTO snapshots | 🟢 `[ACTIVE PROD]` |
| 🛠️ [`scripts/`](scripts/) | Operational shell utilities for LXC cloning, backup, SSH hardening | 🟡 `[ACTIVE]` |
| 📜 [`terraform/`](terraform/) | Terraform / OpenTofu VM cloning blueprints for Proxmox VE | 🟡 `[ACTIVE]` |

## 🛠️ Operational Scripts in [`scripts/`](scripts/)

| Script | Purpose |
|:---|:---|
| `clone_pct.sh` | Clone an LXC container from a template |
| `destroy_pct.sh` | Safely destroy an LXC container |
| `proxmox_backup.sh` | Automated vzdump backup with retention |
| `restore_pct.sh` | Restore an LXC container from backup |
| `clean_old_vzdump.sh` | Remove old backups by retention policy |
| `ssh_hardening.sh` | Apply SSH security best practices to the host/LXC |
| `set_timezone.sh` | Set system timezone on Proxmox host/LXC |
| `show_ip_pct.sh` | List IP addresses of all running containers |
| `vm-deploy-hook.sh` | Post-clone VM deployment hook |
| `deploy_teleport_agent.sh` | Bootstrap a Teleport node agent on new containers |

## 🚀 Quick Usage

```bash
cd Proxmox/scripts
chmod +x *.sh
./clone_pct.sh --help   # shows usage for each script
```

## 📝 Compatibility Notes

- Tested and hardened on **Proxmox VE 8.x and 9.x** (Kernel 6.8 / 6.17+).
- All scripts are idempotent — safe to re-run.
