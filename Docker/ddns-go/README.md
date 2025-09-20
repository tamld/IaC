# 🔄 DDNS-Go (Sanitised Setup)

A lightweight Dynamic DNS client pre-configured with safe defaults. All provider credentials must be supplied via the web UI or your own `.env.local` (not committed).

## 📁 Structure

```
ddns-go/
├── docker-compose.yml   # Container definition
├── README.md            # Documentation
└── config/              # Data directory (empty placeholder)
```

## 🚀 Deploy

```bash
cd ddns-go
docker-compose up -d
```

Access the UI at `http://localhost:9876` (or via your reverse proxy). Configure your DNS provider, token, and domain through the web interface.

## 🔐 Sanitisation Notes

- No provider API keys are stored in this repo.
- Mount `config/` to persist your settings.
- Place any sensitive overrides into `.env.local` and add it to your `.gitignore`.

## 🌐 Typical Integrations

- Traefik or Caddy for HTTPS access.
- Monitoring stack (Prometheus/Grafana) for availability tracking.

## ⚙️ Healthcheck

The Compose file exposes a simple HTTP healthcheck to ensure DDNS-Go starts correctly.
