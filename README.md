<div align="center">

# 🏗️ Infrastructure as Code (IaC)

**Battle-tested, Zero-Trust blueprints for self-hosted infrastructure — from bare metal to containers & Podman LXC**

[![Shell Script](https://img.shields.io/badge/Shell-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)
[![Podman](https://img.shields.io/badge/Podman-892CA0?style=for-the-badge&logo=podman&logoColor=white)](#)
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](#)
[![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=for-the-badge&logo=traefik&logoColor=white)](#)
[![MIT License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#)

**English** · [Issues](https://github.com/tamld/IaC/issues)

</div>

---

## 📌 Overview

A structured, production-hardened collection of Infrastructure as Code blueprints, `docker-compose` stacks, Podman LXC automation scripts, and self-healing patterns for **self-hosted, high-resilience homelabs**.

All content is built on real-world operational experience managing 15+ containerized services with:
- **Zero-Root & Least-Privilege**: Minimal attack surface with non-root execution and dropped Linux capabilities.
- **Daemonless Podman on LXC**: 80% less memory overhead than heavy Docker VMs.
- **Lightweight Observability**: Fast, low-RAM telemetry with VictoriaMetrics, VictoriaLogs, Beszel, and Uptime Kuma.
- **Zero-Trust IAM**: Centralized ForwardAuth SSO with Authelia and LLDAP.
- **Bounded Self-Healing**: Automated Circuit Breaker preventing container crash-loops from burning CPU/IO.

---

## 🏗️ 7-Layer Homelab Architecture Blueprint

```mermaid
flowchart TD
    subgraph L1_L2["🌐 Layer 1 & 2: Hardware & Edge Network"]
        HW["Mini PC (Intel N100 / Proxmox VE 9.x)"]
        Router["MikroTik RouterOS Gateway (VLANs / Subnets)"]
        CF["Cloudflare Edge + DNS + WAF"]
    end

    subgraph L3["🛡️ Layer 3: Edge Ingress & Defense-in-Depth"]
        Traefik["Traefik v3 Reverse Proxy"]
        CrowdSec["CrowdSec IPS / Bouncer"]
        Authelia["Authelia + LLDAP (Zero-Trust ForwardAuth)"]
    end

    subgraph L4["📦 Layer 4: Platform & Core Apps (Podman LXC)"]
        Vault["Vaultwarden (Secrets)"]
        Git["Gitea (Git & CI/CD)"]
        Apps["Home & Admin Dashboards"]
    end

    subgraph L5["📊 Layer 5: Observability & Circuit Breaker"]
        VM["VictoriaMetrics (PromQL TSDB)"]
        VL["VictoriaLogs (LogsQL Central Logs)"]
        Beszel["Beszel Hub + Fleet Agents"]
        Kuma["Uptime Kuma (Dual-Layer Canary Probes)"]
        CB["Systemd Circuit Breaker (StartLimit=600 + OnFailure Hook)"]
    end

    subgraph L6["💾 Layer 6: Backup & Disaster Recovery (3-2-1)"]
        PBS["Proxmox Backup Server (Chunk Deduplication)"]
        SQLiteBackup["Online SQLite Atomic VACUUM"]
    end

    CF --> Router --> Traefik
    Traefik <--> CrowdSec
    Traefik <--> Authelia
    Traefik --> Vault & Git & Apps
    Vault & Git & Apps & HW --> Beszel & VM & VL & Kuma
    CB -->|Crash-Loop Alert| Telegram["📱 Telegram Alert Topic"]
    Vault & Git & Apps --> PBS & SQLiteBackup
```

---

## 📁 Repository Structure

```
IaC/
├── Docker/                      🐳 Production-Ready Compose & Container Stacks
│   ├── authelia-lldap/          🔐 Zero-Trust ForwardAuth & LLDAP Directory Engine
│   ├── beszel/                  🦭 Ultra-light (<10MB RAM) Server & Container Monitor
│   ├── observability-lightweight/ 📊 VictoriaMetrics + VictoriaLogs + Grafana Suite
│   ├── traefik/                 ⚡ Traefik v3 Gateway + CrowdSec + Defense Chain
│   ├── vaultwarden/             🔑 Bitwarden-compatible Secret Vault (Zero-Root)
│   ├── gitea/                   🔄 Self-hosted Git Platform + Actions Runner
│   ├── adguard-home/            🛡️ Network-wide DNS Ad & Tracker Blocking
│   ├── caddy/                   ⚡ Automatic HTTPS Reverse Proxy Alternative
│   ├── ddns-go/                 🌐 Multi-provider Dynamic DNS Updater
│   ├── wg-easy/                 🔒 WireGuard VPN with Web UI
│   ├── teleport/                🔐 Zero-Trust Infrastructure Access Gateway
│   ├── wazuh/                   🛡️ SIEM + EDR + Host Compliance
│   └── woodpecker/              🔄 Gitea-native CI/CD Pipeline Runner
│
├── Proxmox/                     🖥️ Proxmox VE Automation & Resilience Blueprints
│   ├── circuit-breaker/         ⚡ Bounded Self-Healing & Systemd Circuit Breakers
│   ├── podman-lxc/              🦭 Daemonless Podman Container Provisioning on LXC
│   ├── sqlite-maintenance/      🗄️ Non-blocking Live SQLite Backups & Auto-Vacuum
│   ├── scripts/                 🛠️ Shell utilities for LXC cloning, backup, SSH hardening
│   └── terraform/               📜 Terraform provider modules for Proxmox VE
│
├── VMware/                      💻 VMware ESXi/vSphere templates
└── Virtualbox/                  📦 VirtualBox local dev environments & automation
```

---

---

## 📜 Architectural Evolution & Lifecycle Matrix

> *"Systems mature as constraints, security insights, and scale evolve."*

| Stack / Technology | Lifecycle Status | Architectural Evolution & Hardening Rationale | Successor / Recommended Choice |
|:---|:---:|:---|:---|
| **[Observability Suite](Docker/observability-lightweight/)** | 🟢 `[ACTIVE PROD]` | **Replaced heavy Prometheus+Loki**: Saves 85% RAM (~180MB footprint) on Mini PCs using VictoriaMetrics + VictoriaLogs. | **Current Production Standard** |
| **[Beszel Fleet Monitor](Docker/beszel/)** | 🟢 `[ACTIVE PROD]` | **Replaced cAdvisor+NodeExporter**: <10MB RAM per node, zero-config SSH ed25519 authentication. | **Current Production Standard** |
| **[Authelia + LLDAP](Docker/authelia-lldap/)** | 🟢 `[ACTIVE PROD]` | **Replaced per-app auth & heavy Keycloak**: Zero-Trust ForwardAuth with delegated `admins` group permissions. | **Current Production Standard** |
| **[Traefik v3 Gateway](Docker/traefik/)** | 🟢 `[ACTIVE PROD]` | **Replaced static Caddy configs**: Hot-reloading YAML routers + CrowdSec IPS + Circuit Breaker middlewares. | **Current Production Standard** |
| **[Podman on LXC](Proxmox/podman-lxc/)** | 🟢 `[ACTIVE PROD]` | **Replaced heavy Docker VMs & Privileged LXCs**: Daemonless containerization managed directly by Systemd. | **Current Production Standard** |
| **[Systemd Circuit Breaker](Proxmox/circuit-breaker/)** | 🟢 `[ACTIVE PROD]` | **Replaced infinite `Restart=always`**: Trips after 5 crashes in 10min, halts IO thrashing, fires Telegram alert. | **Current Production Standard** |
| **[Vaultwarden](Docker/vaultwarden/)** | 🟢 `[ACTIVE PROD]` | **Hardened to Zero-Root**: `user: 1000:1000`, `cap_drop: [ALL]`, automated atomic `VACUUM INTO` live backups. | **Current Production Standard** |
| **[Gitea Git Platform](Docker/gitea/)** | 🟢 `[ACTIVE PROD]` | **Migrated to Rootless Architecture**: `gitea-rootless` on custom SSH `:2222` port. | **Current Production Standard** |
| **[Prometheus Stack](Docker/monitor/)** | 📦 `[HISTORICAL]` | Kept for large enterprise setups requiring multi-tenant Alertmanager routing or Thanos clustering. | [`observability-lightweight/`](Docker/observability-lightweight/) |
| **[Caddy Reverse Proxy](Docker/caddy/)** | 📦 `[HISTORICAL]` | Kept for quick single-VPS or local development staging requiring zero-config Auto-TLS. | [`traefik/`](Docker/traefik/) |
| **[Teleport Gateway](Docker/teleport/)** | 📦 `[HISTORICAL]` | Kept for regulated multi-engineer teams requiring SOC2 live terminal audit session recording. | [`authelia-lldap/`](Docker/authelia-lldap/) + Tailscale |
| **[VMware & VirtualBox](VMware/)** | 🟡 `[STANDALONE]` | Vagrant & Ansible playbooks for local developer workstations (Win11/Ubuntu testbeds). | **Standalone Dev Tooling** |

---

## 🚀 Featured Production Stacks

| Stack | Category | Main Highlights | Documentation |
|:---|:---|:---|:---:|
| **[Observability Suite](Docker/observability-lightweight/)** | 📊 Telemetry | 85% less RAM than Prometheus/Loki; unified LogsQL & PromQL | [Read Guide](Docker/observability-lightweight/) |
| **[Beszel Fleet Monitor](Docker/beszel/)** | 🦭 Hardware Metrics | <10MB RAM agent; native CPU/RAM/Disk and Docker charts | [Read Guide](Docker/beszel/) |
| **[Authelia + LLDAP](Docker/authelia-lldap/)** | 🔐 Zero-Trust IAM | Single Sign-On (SSO); Traefik ForwardAuth; `admins` delegation | [Read Guide](Docker/authelia-lldap/) |
| **[Podman on LXC](Proxmox/podman-lxc/)** | 🦭 Container Runtime | Daemonless; native systemd unit control; zero Docker VM overhead | [Read Guide](Proxmox/podman-lxc/) |
| **[Systemd Circuit Breaker](Proxmox/circuit-breaker/)** | ⚡ Self-Healing | Bounded auto-restart; stops crash loops; instant Telegram triage | [Read Guide](Proxmox/circuit-breaker/) |
| **[Traefik v3 Defense](Docker/traefik/)** | 🛡️ Edge Router | Multi-layer chain: CrowdSec IPS + RateLimit + Circuit Breaker | [Read Guide](Docker/traefik/) |
| **[SQLite Auto-Vacuum](Proxmox/sqlite-maintenance/)** | 🗄️ Database Backup | Atomic `VACUUM INTO` live snapshots without container stoppage | [Read Guide](Proxmox/sqlite-maintenance/) |

---

## 🔒 Zero-Leakage & Security Governance Standard

This repository strictly enforces the **Zero-Leakage Data Loss Prevention (DLP)** standard:
- **No Hardcoded Secrets**: All credentials use `.env.example` templates with generic placeholders.
- **Sanitized Network Topology**: All domains use `example.com` / `homelab.internal`; all subnets use standard RFC 1918 addresses (`10.0.0.0/24`, `192.168.1.0/24`).
- **No Binary DB Dumps**: No raw `.sqlite3`, `.db`, or private keys (`.pem`, `.key`) are committed to Git.

---

## 🤝 Contributing

Contributions and improvements are welcome! Please ensure:
1. Every new service stack has a dedicated `README.md` with an architecture flowchart.
2. Configuration files use `.env.example` with zero sensitive credentials.
3. Commit messages follow Conventional Commits: `feat(podman): add ...`

---

<div align="center">

Made with ☕ by [tamld](https://github.com/tamld) &nbsp;|&nbsp; ⭐ Star this repo if it helped your homelab journey!

</div>
