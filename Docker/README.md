# 🐳 Docker — Self-Hosted Stacks

Production-ready Docker Compose stacks for common self-hosted services.

Each subdirectory contains a standalone `docker-compose` file with its own `README.md`.

## Available Stacks

| Stack | Category | Description |
|-------|----------|-------------|
| [adguard-home](adguard-home/) | 🛡️ DNS | Network-level ad and tracker blocking |
| [caddy](caddy/) | 🔀 Reverse Proxy | Automatic HTTPS with simple config |
| [ddns-go](ddns-go/) | 🌐 Dynamic DNS | Multi-provider DDNS updater |
| [kutt](kutt/) | 🔗 URL Shortener | Self-hosted link shortener (PostgreSQL/MariaDB) |
| [monitor](monitor/) | 📊 Observability | Prometheus + Grafana monitoring stack |
| [teleport](teleport/) | 🔐 Zero-Trust Access | Unified SSH/Kubernetes/DB gateway |
| [traefik](traefik/) | ⚡ Edge Router | Automatic TLS, service discovery |
| [vaultwarden](vaultwarden/) | 🔑 Password Manager | Bitwarden-compatible (Rust-based) |

## Usage

```bash
cd <stack-name>
cp .env.example .env    # if provided
$EDITOR .env            # set domain, passwords, etc.
docker compose up -d
docker compose logs -f
```

## Notes

- All stacks use `restart: unless-stopped` by default
- Secrets go in `.env.local` (gitignored) — never commit real credentials
- Each stack's `README.md` contains service-specific setup instructions