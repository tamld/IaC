# 📊 Monitor Stack — Prometheus + Grafana

Full observability stack: metrics collection, alerting, and dashboard visualization.

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | `9090` | Metrics scraping & storage |
| Grafana | `3000` | Dashboard UI |
| Node Exporter | `9100` | Host system metrics |

## Quick Start

```bash
docker compose up -d
# Grafana at http://<host>:3000 (default: admin/admin)
# Prometheus at http://<host>:9090
```

## Adding Scrape Targets

Edit `prometheus.yml` under `scrape_configs`:

```yaml
- job_name: 'my-service'
  static_configs:
    - targets: ['host.docker.internal:8080']
```

## Notes

- Change Grafana default password on first login
- Prometheus data persisted in named volume `prometheus_data`
- Import pre-built dashboards from [grafana.com/dashboards](https://grafana.com/grafana/dashboards/)
