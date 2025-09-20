# 🌐 Caddy Reverse Proxy (Sanitised)

Ready-to-share Caddy configuration wired for Cloudflare-origin certificates and optional DDNS. Replace placeholders (`example.lab`, IPs) before production use.

## 📁 Structure

```
caddy/
├── caddy/
│   ├── Caddyfile              # Core server config (imports headers/sites)
│   ├── docker-compose.yml     # Caddy container definition
│   ├── .env.example           # Domain base placeholder
│   ├── headers/               # Shared header snippets
│   └── sites/                 # Site-specific configs
├── cloudflare/
│   └── origin/                # Place your origin cert/key here (gitignored)
└── ddns-go/                   # Optional ddns-go companion stack
```

## 🚀 Usage

1. Copy `.env.example` to `.env` and set `CADDY_DOMAIN_BASE` (e.g., `example.lab`).
2. Drop your Cloudflare origin cert/key under `cloudflare/origin/`.
3. Review `sites/teleport.caddy` and replace backend IP with your Teleport endpoint.
4. Launch Caddy:
   ```bash
   docker compose up -d
   ```

## 🔐 Sanitisation Notes

- `teleport.caddy` uses `https://192.0.2.10:3080` (documentation-only IP). Update it to your host.
- `.env.example` ships with placeholder domain.
- Certificates, logs, and runtime files are ignored via `.gitignore`.

## ➕ Optional DDNS

Use the bundled `ddns-go` stack under `ddns-go/` to keep Cloudflare records updated.
