# 🔀 Caddy — Automatic HTTPS Reverse Proxy

Zero-config TLS via Let's Encrypt. Simpler alternative to Nginx/Traefik for most setups.

## Quick Start

```bash
$EDITOR Caddyfile   # Set your domain and upstreams
docker compose up -d
```

## Example Caddyfile

```caddyfile
example.com {
    reverse_proxy app:3000
}
```

## Notes

- Caddy auto-obtains and renews TLS certificates
- Config hot-reload: `docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile`
- Data (certs, ACME state) persisted in named volume `caddy_data`
