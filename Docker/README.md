# 🐳 Docker — Self-Hosted Stacks

Production-ready Docker Compose stacks, each with `docker-compose.yml` + `README.md` + `.env.example`.

---

## 🌐 Networking & Routing
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [traefik](traefik/) | 55k+ | Edge router, automatic TLS, service discovery |
| [caddy](caddy/) | 60k+ | Reverse proxy with automatic HTTPS |
| [ddns-go](ddns-go/) | 7k+ | Multi-provider Dynamic DNS updater |

## 🔒 Security, Access & VPN
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [adguard-home](adguard-home/) | 26k+ | Network-level DNS ad/tracker blocking |
| [vaultwarden](vaultwarden/) | 43k+ | Bitwarden-compatible password manager |
| [teleport](teleport/) | 18k+ | Zero-trust SSH / Kubernetes / DB gateway |
| [wg-easy](wg-easy/) | 17k+ | WireGuard VPN with web UI + QR codes |

## 🛡️ Security Audit & SIEM
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [wazuh](wazuh/) | 11k+ | Full SIEM + EDR + compliance (PCI-DSS, HIPAA, GDPR) |
| [greenbone](greenbone/) | 4k+ | OpenVAS network vulnerability scanner |

## 🔄 Git Version Control & CI/CD
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [gitea](gitea/) | 45k+ | Self-hosted GitHub alternative — Git, Issues, PRs, Packages, Actions |
| [woodpecker](woodpecker/) | 4k+ | Gitea-native CI/CD pipelines, Docker-based runners |

## 📊 Observability
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [monitor](monitor/) | — | Prometheus + Grafana observability stack |

## 💼 Business Apps & Knowledge Base
| Stack | ⭐ Stars | Description |
|-------|---------|-------------|
| [plane](plane/) | 32k+ | Jira/Linear alternative — issues, cycles, sprints |
| [twenty](twenty/) | 28k+ | Salesforce alternative — contacts, pipeline, custom objects |
| [outline](outline/) | 29k+ | Team wiki / knowledge base (Notion-like) |

---

## Usage

```bash
cd <stack-name>
cp .env.example .env && $EDITOR .env
docker compose up -d
docker compose logs -f
```
