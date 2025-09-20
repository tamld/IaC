# 🏗️ Infrastructure as Code (IaC) Repository

Public, sanitised mirror of the homelab IaC assets. Everything here keeps the structure and practices of the private repo, but substitutes sensitive values with documentation-friendly placeholders.

## 📚 Table of Contents

| Platform | Description |
|----------|-------------|
| 🖥️ [Proxmox](./Proxmox/) | Hardened automation scripts, docs, and Terraform modules |
| 💻 [VirtualBox](./Virtualbox/) | Cross-platform virtualization examples |
| 🌀 [VMware](./VMware/) | VMware templates & runbooks |
| 🐳 [Docker](./Docker/) | Compose stacks: Traefik, Teleport, Monitoring, etc. |

## 🚀 Getting Started

- 🖥️ **[Proxmox](./Proxmox/README.md)** – Backups, cloning, Teleport agents, and documentation bundles.
- 🐳 **[Docker](./Docker/README.md)** – Container stacks with `.env.example` templates and gitignored secrets.
- 💻 **[VirtualBox](./Virtualbox/README.md)** – Vagrant-based workflows.
- 🌀 **[VMware](./VMware/README.md)** – Enterprise virtualization guidance.

## 🌐 Capabilities

- VM/CT lifecycle automation and Cloud-Init provisioning
- Multi-tier backup orchestration with retention policies
- Reverse proxies (Traefik, Caddy) and access plane (Teleport)
- Monitoring & alerting (Prometheus, Grafana, Alertmanager)

## 🛠️ Toolchain Snapshot

| Tool | Role |
|------|------|
| Terraform | Declarative infrastructure provisioning |
| Ansible | Configuration management |
| Bash | Proxmox automation scripts |
| Docker Compose | Service orchestration |
| Cloud-Init | VM initialisation |

## 📋 Repository Structure

```
IaC/
├── Proxmox/              # Scripts, docs, Terraform modules (sanitised)
│   ├── docs/
│   ├── scripts/
│   └── terraform/
├── Docker/               # Compose bundles with example configs
│   ├── traefik/
│   ├── teleport/
│   ├── monitor/
│   ├── adguard-home/
│   ├── ddns-go/
│   ├── vaultwarden/
│   └── caddy/
├── Virtualbox/
└── VMware/
```

## 🔐 Sanitisation Practices

1. `.env.example` files document required secrets; real `.env` files stay local.
2. Placeholder domains/IPs follow RFC sample ranges (`example.lab`, `192.0.2.x`).
3. Alerting/webhook configs rely on `REPLACE_ME_*` markers so tokens never leak.

## 📝 Contributing

PRs are welcome—keep new content anonymised and clearly documented.

## 📄 License

MIT – see `LICENSE`.
