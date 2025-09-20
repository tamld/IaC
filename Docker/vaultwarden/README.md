# 🔒 Vaultwarden (Bitwarden Compatible)

Sanitised compose bundle for self-hosted password management. Replace the placeholders in `.env.example` before deploying.

## 📁 Files

```
vaultwarden/
├── compose.yaml       # Docker Compose definition
├── README.md          # This guide
├── .env.example       # Environment template (no secrets)
└── vw-data/           # Data volume placeholder
```

## 🚀 Deploy

1. Copy `.env.example` to `.env` and set `DOMAIN`, `ADMIN_TOKEN`, etc.
2. Create the admin token hash: `openssl rand -base64 48 | docker run --rm vaultwarden/server:latest argon2 '$TOKEN'`.
3. Launch the stack:
   ```bash
   docker compose --env-file .env up -d
   ```
4. Expose via Traefik/Caddy for HTTPS.

## 🔐 Sanitisation Notes

- `DOMAIN` defaults to `https://vault.example.lab`.
- `ADMIN_TOKEN` is set to `GENERATE_YOUR_OWN_HASH` placeholder.
- Signups are disabled by default; enable if needed.

Persisted data lives under `vw-data/` (ignored by git).
