# 🔑 Vaultwarden — Self-Hosted Password Manager

Lightweight, Bitwarden-compatible server written in Rust. Works with all official Bitwarden clients.

## Port

| Port | Purpose |
|------|---------|
| `80` | Web Vault UI (proxy to HTTPS recommended) |

## Quick Start

```bash
$EDITOR .env   # Set DOMAIN, ADMIN_TOKEN, SMTP settings
docker compose up -d
# Web Vault at http://<host> (or via reverse proxy)
```

## Recommended Setup

- Put behind Traefik or Caddy for automatic HTTPS
- Set `SIGNUPS_ALLOWED=false` after creating your account
- Enable 2FA (TOTP) from the Web Vault settings

## Notes

- All data stored in `./vw-data/` (back this up!)
- Admin panel at `/admin` (requires `ADMIN_TOKEN`)
- Compatible with: Bitwarden browser extension, iOS, Android, Desktop app
