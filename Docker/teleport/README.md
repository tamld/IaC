# 🔐 Teleport Access Plane (Sanitised Bundle)

This directory provides a docker-compose deployment for Teleport with all lab-specific values replaced by placeholders. Pair it with `Proxmox/scripts/deploy_teleport_agent.sh` to bootstrap agents inside your containers.

## 📁 Structure

```
teleport/
├── docker-compose.yml          # Teleport in single-node mode
├── README.md                   # This guide
├── .env.example                # Required environment variables
├── config/teleport.template.yaml # Template rendered by deploy.sh
├── scripts/deploy.sh           # Helper to render config + manage secrets
├── scripts/manage-secrets.sh   # Simple wrapper for secret encryption (mock)
└── secrets/                    # Placeholder for encrypted secrets (ignored)
```

## 🚀 Quick Start

1. Copy `.env.example` to `.env` and set your cluster details, tokens, and pins.
2. Populate `secrets/` with your encrypted secrets (see README comments) or integrate with your own secret manager.
3. Run `./scripts/deploy.sh up` to render config and start Teleport.
4. Use `./scripts/deploy.sh down` to stop the service and clear generated config.

## 🔐 Sanitisation

- No real domains or tokens are shipped. All values are placeholders (e.g., `teleport.example.lab`).
- Secrets remain encrypted (`*.secret.enc`) or mocked; the sample script demonstrates the workflow without exposing real data.

## 🤝 Agents

Use `../../Proxmox/scripts/deploy_teleport_agent.sh` to roll Teleport agents to your Proxmox containers with the parameters defined in `.env`.

Adapt the templates to your infrastructure before going live.
