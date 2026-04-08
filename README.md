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
│   ├── gitea/           Self-hosted GitHub alternative + Actions
│   ├── greenbone/       OpenVAS network vulnerability scanner
│   ├── monitor/         Prometheus + Grafana observability stack
│   ├── outline/         Team knowledge base (Notion-like)
│   ├── plane/           Project management — Jira/Linear alternative
│   ├── teleport/        Zero-trust infrastructure access
│   ├── traefik/         Edge router & load balancer
│   ├── twenty/          CRM — Salesforce alternative
│   ├── vaultwarden/     Bitwarden-compatible password manager
│   ├── wazuh/           SIEM + EDR + compliance platform
│   ├── wg-easy/         WireGuard VPN with web UI
│   └── woodpecker/      Gitea-native CI/CD pipelines
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

| Service | ⭐ Stars | Category | Notes |
|---------|---------|----------|-------|
| [Traefik](Docker/traefik/) | 55k+ | ⚡ Reverse Proxy | Edge router, auto TLS |
| [Caddy](Docker/caddy/) | 60k+ | ⚡ Reverse Proxy | Simple automatic HTTPS |
| [Gitea](Docker/gitea/) | 45k+ | 🔄 Git + CI/CD | Self-hosted GitHub alternative |
| [Woodpecker CI](Docker/woodpecker/) | 4k+ | 🔄 CI/CD | Gitea-native pipeline runner |
| [Wazuh](Docker/wazuh/) | 11k+ | 🛡️ SIEM | EDR + compliance + vulnerability |
| [Greenbone](Docker/greenbone/) | 4k+ | 🔍 Scanner | OpenVAS network scanner |
| [wg-easy](Docker/wg-easy/) | 17k+ | 🔒 VPN | WireGuard with web UI |
| [Teleport](Docker/teleport/) | 18k+ | 🔐 Zero-Trust | SSH/K8s/DB access gateway |
| [Vaultwarden](Docker/vaultwarden/) | 43k+ | 🔑 Security | Bitwarden-compatible password manager |
| [AdGuard Home](Docker/adguard-home/) | 26k+ | 🛡️ DNS | Network-level ad/tracker blocking |
| [Plane](Docker/plane/) | 32k+ | 🎯 Project Mgmt | Jira/Linear alternative |
| [Twenty CRM](Docker/twenty/) | 28k+ | 💼 CRM | Salesforce alternative |
| [Outline](Docker/outline/) | 29k+ | 📚 Knowledge Base | Notion-like team wiki |
| [Monitor Stack](Docker/monitor/) | — | 📊 Observability | Prometheus + Grafana |
| [DDNS-Go](Docker/ddns-go/) | 7k+ | 🌐 DNS | Dynamic DNS updater |
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


---

## 🤖 AI Management Roadmap

> **Vision**: Deploy first, then progressively delegate control to AI agents — from human operations to autonomous, scenario-based governance.

### 🟢 Phase 1 — Foundation: Manual Deploy *(Now)*
- All stacks deployed via `docker compose up -d`
- Repos hosted in Gitea, pipelines in Woodpecker CI
- Monitoring via Prometheus + Grafana
- Security: Wazuh SIEM + Greenbone CVE scans

**Goal**: Every service up, documented, operational.

---

### 🔵 Phase 2 — Observe: Centralized Telemetry
- All logs stream into Wazuh SIEM
- All metrics flow into Prometheus
- Gitea webhooks trigger Woodpecker pipelines on every commit
- Greenbone scheduled CVE scans → auto-generate PDF reports

**Goal**: Full visibility. Zero blind spots.

---

### 🟡 Phase 3 — Automate: AI-Assisted Monitoring
| AI Task | Input | Output |
|---------|-------|--------|
| Incident Summarizer | Wazuh alert | Human-readable root-cause + suggested fix |
| Anomaly Detector | Prometheus metrics | Alert + degradation trend graph |
| CVE Triage | Greenbone report | Prioritized remediation → Plane ticket |
| PR Reviewer | Gitea webhook | Code review summary → comment on PR |

**Tools**: Ollama (local LLM) · OpenAI API · n8n workflow automation

---

### 🔴 Phase 4 — Autonomous: Scenario-Based Self-Governance
| Scenario | Trigger | AI Response |
|---------|---------|-------------|
| Container down | Health check fail | Restart → verify → alert if persists |
| CVE detected | Greenbone scan | Open Plane ticket → assign priority → notify |
| Unusual login | Wazuh rule 5710 | Block IP via Traefik WAF → notify admin |
| High CPU | Prometheus threshold | Identify process → scale or kill → report |
| CI build fail | Woodpecker webhook | AI diagnoses error → suggests fix → opens PR |

**Tools**: [n8n](https://github.com/n8n-io/n8n) (36k⭐) · LangChain · CrewAI

---

### 🟣 Phase 5 — Self-Evolving Infrastructure
- AI reviews weekly metrics and proposes `docker-compose.yml` optimizations as Gitea PRs
- Auto-generates Grafana dashboards for newly deployed services
- Continuously updates documentation (this repo) from incident learnings
- Gitea + Woodpecker CI auto-tests every infrastructure change locally

> 💡 **This repository is the foundation.** Each stack is an independently operable unit that, together, forms a complete self-hosted platform ready for AI agent oversight.

## 🤝 Contributing

PRs welcome. Please ensure:
- Each stack/script has a `README.md`
- Changes are tested in a staging environment first
- Commit messages follow conventional commits: `feat(docker): add ...`

---

<div align="center">

Made with ☕ by [tamld](https://github.com/tamld) &nbsp;|&nbsp; ⭐ Star this repo if it helped you

</div>