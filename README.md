<div align="center">

# 🏗️ Infrastructure as Code (IaC)

**Battle-tested templates for self-hosted infrastructure — from bare metal to containers**

[![Shell Script](https://img.shields.io/badge/Shell-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](#)
[![VMware](https://img.shields.io/badge/VMware-607078?style=for-the-badge&logo=vmware&logoColor=white)](#)
[![VirtualBox](https://img.shields.io/badge/VirtualBox-183A61?style=for-the-badge&logo=virtualbox&logoColor=white)](#)
[![MIT License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#)

**English** · [Issues](https://github.com/tamld/IaC/issues)

</div>

---

## 📌 Overview

A structured collection of Infrastructure as Code templates, `docker-compose` stacks, and shell scripts designed for **self-hosted, production-grade environments**.

All content is built around real-world operational experience managing on-premise infrastructure with:
- Idempotent scripts safe to re-run
- Minimal external dependencies
- Clear, copy-paste-ready configurations

---

## 📁 Repository Structure

```
IaC/
├── Docker/          🐳 Docker Compose stacks for self-hosted services
│   ├── adguard-home/    DNS-level ad blocking
│   ├── caddy/           Automatic HTTPS reverse proxy
│   ├── ddns-go/         Dynamic DNS updater
│   ├── kutt/            URL shortener
│   ├── monitor/         Prometheus + Grafana observability stack
│   ├── teleport/        Zero-trust infrastructure access
│   ├── traefik/         Edge router & load balancer
│   └── vaultwarden/     Bitwarden-compatible password manager
│
├── Proxmox/         🖥️ Proxmox VE automation scripts
│   ├── scripts/         LXC clone, backup, restore, SSH hardening, timezone
│   └── terraform/       Terraform provider for Proxmox
│
├── VMware/          💻 VMware ESXi/vSphere templates
└── Virtualbox/      📦 VirtualBox local dev environments + restore scripts
```

---

## 🐳 Docker Stacks

Each stack is a standalone `docker-compose` configuration with its own `README.md`.

| Service | Category | Notes |
|---------|----------|-------|
| [AdGuard Home](Docker/adguard-home/) | 🛡️ DNS / Ad-blocking | Network-level blocker with admin UI |
| [Caddy](Docker/caddy/) | 🔀 Reverse Proxy | Automatic TLS, simple Caddyfile syntax |
| [DDNS-Go](Docker/ddns-go/) | 🌐 Dynamic DNS | Supports Cloudflare, Aliyun, Namecheap +more |
| [Kutt](Docker/kutt/) | 🔗 URL Shortener | Self-hosted with PostgreSQL or MariaDB backend |
| [Monitor Stack](Docker/monitor/) | 📊 Observability | Prometheus + Grafana, pre-built dashboards |
| [Teleport](Docker/teleport/) | 🔐 Zero-Trust Access | Unified SSH/K8s/DB access gateway |
| [Traefik](Docker/traefik/) | ⚡ Edge Router | Auto service discovery, Let's Encrypt TLS |
| [Vaultwarden](Docker/vaultwarden/) | 🔑 Password Manager | Bitwarden-compatible, Rust-based |

---

## 🖥️ Proxmox Scripts

Located in [`Proxmox/scripts/`](Proxmox/scripts/):

| Script | Purpose |
|--------|---------|
| `clone_pct.sh` | Clone LXC container from template |
| `destroy_pct.sh` | Safely destroy LXC container |
| `proxmox_backup.sh` | Automated vzdump backup routine |
| `restore_pct.sh` | Restore LXC from backup |
| `clean_old_vzdump.sh` | Purge old backup files by retention policy |
| `ssh_hardening.sh` | Apply SSH security best practices |
| `set_timezone.sh` | Set system timezone on PVE host |
| `show_ip_pct.sh` | List IP addresses of running containers |
| `vm-deploy-hook.sh` | Post-clone VM deployment hook |
| `deploy_teleport_agent.sh` | Bootstrap Teleport node agent |

Also includes **Terraform** configs for Proxmox: see [`Proxmox/terraform/`](Proxmox/terraform/).

---

## 🚀 Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/tamld/IaC.git && cd IaC

# 2. Pick a Docker stack
cd Docker/traefik
cp .env.example .env   # if available
$EDITOR .env           # set your domain, credentials
docker compose up -d

# 3. For Proxmox scripts
cd Proxmox/scripts
chmod +x *.sh
./clone_pct.sh --help
```

---

## 🧭 Design Principles

- **Idempotency** — Scripts are safe to run multiple times
- **Portability** — Minimize host-level dependencies; standard tools only
- **Simplicity** — Prefer readability over cleverness
- **Documentation** — Every folder has its own `README.md`

---

## 🤝 Contributing

PRs welcome. Please ensure:
- Each stack/script has a `README.md`
- Changes are tested in a staging environment first
- Commit messages follow conventional commits: `feat(docker): add ...`

---

<div align="center">

Made with ☕ by [tamld](https://github.com/tamld) &nbsp;|&nbsp; ⭐ Star this repo if it helped you

</div>