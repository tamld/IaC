# 📊 Monitoring Stack (Prometheus + Grafana + Alertmanager)

A docker-compose bundle for observability. All secrets (e.g., Telegram tokens) are replaced with placeholders to keep this repo safe for sharing.

## 📁 Contents

```
monitor/
├── docker-compose.yaml        # Prometheus, Alertmanager, Grafana
├── prometheus.yml             # Base Prometheus config
├── alertmanager/alertmanager.yml # Sanitised alert routing (fill in secrets)
├── alert-rules/               # Example alert rules
├── grafana/                   # Provisioning stubs for dashboards & alerting
├── exporters/                 # Placeholder for node-exporter etc.
└── README.md
```

## 🚀 Getting Started

1. Copy `alertmanager/alertmanager.yml` to `alertmanager/alertmanager.local.yml` and populate placeholders (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`).
2. Update `docker-compose.yaml` to mount the local override (example included in comments).
3. Bring the stack up:
   ```bash
   docker-compose up -d
   ```
4. Access Grafana at `http://localhost:3001` (default admin credentials: `admin/admin`).

## 🔐 Sanitisation Notes

- Telegram token, chat id, and thread id values are set to `REPLACE_ME`.
- No dashboards or secrets are included; use Grafana provisioning stubs to import your own.

## 📦 Exporters

Add exporters under `exporters/` and extend `prometheus.yml` scrape configs.

## 🛠️ Tooling

`init_project.sh` from the private repo is not required here. Create folders as needed; `.gitkeep` files are provided so empty dirs persist.
