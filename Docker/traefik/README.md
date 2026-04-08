# ⚡ Traefik — Edge Router & Reverse Proxy

Automatic TLS via Let's Encrypt (Cloudflare DNS challenge), service discovery via Docker labels.

## Ports

| Port | Purpose |
|------|---------|
| `80` | HTTP (redirect to HTTPS) |
| `443` | HTTPS |
| `8080` | Traefik dashboard (optional) |

## Required Files

```
traefik/
├── traefik.yml          # Static configuration
├── dynamic/             # Dynamic configuration (routers, middlewares)
├── acme.json            # TLS certificate store (chmod 600)
├── certs/               # Optional static certs (Cloudflare Origin)
├── logs/                # Access/error logs
├── .env                 # Example values (safe to commit)
└── .env.local           # Real secrets — DO NOT commit
```

## Quick Start

```bash
# Create cert store with correct permissions
touch acme.json && chmod 600 acme.json

cp .env.example .env.local   # if provided
$EDITOR .env.local           # Set DOMAIN, CF_API_TOKEN, etc.
docker compose up -d
```

## Notes

- Uses Cloudflare DNS challenge for wildcard TLS — set `CF_API_TOKEN` in `.env.local`
- Dashboard accessible at `traefik.<DOMAIN>` (protected by `auth@file` middleware)
- Traefik config in `traefik.yml` is mounted read-only