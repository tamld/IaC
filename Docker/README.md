# 🐳 Docker Infrastructure as Code

A curated set of sanitised, ready-to-run Docker setups derived from the private homelab project. Each service replaces sensitive values with placeholders so you can learn from the structure without exposing secrets.

## 📚 Services

| Service | Description |
|---------|-------------|
| [🛡️ AdGuard Home](./adguard-home/) | Network-wide DNS filtering with example config |
| [🔄 DDNS-Go](./ddns-go/) | Dynamic DNS client (UI-driven credentials) |
| [📊 Monitoring Stack](./monitor/) | Prometheus + Alertmanager + Grafana bundle |
| [🔄 Traefik](./traefik/) | Reverse proxy with Cloudflare DNS challenge |
| [🔐 Teleport](./teleport/) | Access plane (auth, proxy, teleport agents) |
| [🔒 Vaultwarden](./vaultwarden/) | Self-hosted password manager |
| [📝 Caddy](./caddy/) | TLS termination + reverse proxy with Cloudflare origins |

## 🔐 Sanitisation Principles

- `.env.example` files document required variables; never commit your real `.env`.
- Tokens, domain names, IPs, and certificate paths use documentation placeholders (`example.lab`, `192.0.2.x`, `REPLACE_ME_*`).
- `.gitignore` entries keep secrets (`.env`, `secrets/`, certs) out of version control.

## 🚀 How to Use

1. Pick a service directory and review its README.
2. Copy the provided `.env.example` (or config templates) to your own workspace and fill in real values.
3. Launch with `docker compose up -d` (or the helper scripts, e.g., `teleport/scripts/deploy.sh up`).
4. Integrate behind `traefik` or `caddy` if you need HTTPS ingress.

## 🧪 Suggested Next Steps

- Wire alerting tokens in `monitor/alertmanager/alertmanager.yml` before production use.
- Replace placeholder TLS certificates in `caddy/cloudflare/origin/`.
- Extend Prometheus scrape configs with your exporters under `monitor/exporters/`.

These samples are intentionally verbose to aid training and knowledge transfer—trim them to match your own operational standards when adopting.
