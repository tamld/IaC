# 🔐 Teleport — Zero-Trust Infrastructure Access

Unified SSH, Kubernetes, and database access gateway with audit logging and role-based access control.

## Ports

| Port | Purpose |
|------|---------|
| `443` | Web UI + API |
| `3022` | SSH proxy |
| `3025` | Teleport auth server |
| `3080` | Web UI (non-TLS fallback) |

## Quick Start

```bash
$EDITOR .env   # Set TELEPORT_DOMAIN, license (if enterprise)
docker compose up -d
# Web UI at https://<host>:443 or https://<TELEPORT_DOMAIN>
```

## Notes

- Free Community Edition supports SSH, K8s, and App access
- Run initial setup: `docker compose exec teleport tctl users add admin --roles=editor,access`
- Agent nodes registered via `deploy_teleport_agent.sh` in `Proxmox/scripts/`
