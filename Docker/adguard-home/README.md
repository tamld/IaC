# 🛡️ AdGuard Home

Network-level DNS ad/tracker blocking with a web admin UI.

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `53` | TCP/UDP | DNS queries |
| `3000` | TCP | Initial setup UI |
| `80` | TCP | Admin UI (optional, behind proxy) |

## Quick Start

```bash
docker compose up -d
# Open http://<host>:3000 for first-time setup
```

## Notes

- Config stored in `./conf/AdGuardHome.yaml` (read-only mount)
- Working data in `./work/`
- Set `TZ` in compose file to your timezone
- Healthcheck runs every 30s via `--check-config`
