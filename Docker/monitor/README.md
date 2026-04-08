<div align="center">
  <img src="https://grafana.com/static/img/menu/grafana2.svg" width="100" />
  &nbsp;&nbsp;
  <img src="https://prometheus.io/assets/prometheus_logo-cb55bb5c346.png" width="80" />
  
  # Observability Stack
  **Prometheus + Grafana Monitoring Infrastructure**
  
  [![Grafana Pulls](https://img.shields.io/docker/pulls/grafana/grafana)](https://hub.docker.com/r/grafana/grafana)
</div>

---

## 📈 What is this Stack?

The Observability stack combines two industry-standard tools:
1. **Prometheus:** A highly efficient time-series database that "scrapes" metrics from your systems and services at regular intervals.
2. **Grafana:** A stunning data visualization frontend that connects to Prometheus to render graphs, gauges, and alerts.

Together, they provide complete visibility into your homelab's hardware health, docker container statistics, and application-specific metrics.

### ✨ Key Features
- **Centralized Metrics:** Aggregate metrics from Node Exporters, cAdvisor, Traefik, or any service exposing `/metrics`.
- **Pre-built Dashboards:** Import thousands of community-built dashboards directly into Grafana with a single ID.
- **Alerting:** Set up Slack/Discord webhook alerts if CPU spikes, disks fill up, or containers crash.

---

## ⚙️ Architecture & Compose Configuration

This stack deploys both containers tightly coupled. Grafana relies on Prometheus to act as its primary Data Source.

### Port Bindings
- `3000:3000` - Grafana Web UI. *(Note: Prometheus is deliberately kept unexposed on the host. Grafana communicates with it entirely over Docker's internal network via `http://prometheus:9090`)*.

### Persistent Volumes
- `prom_data`: Stores the historical time-series metric data over time.
- `grafana_data`: Stores your dashboards, users, and data source configurations.
- `./prometheus.yml`: A critical configuration file mapping out your scrape targets.

---

## 🚀 Getting Started

### 1. Configure Prometheus Scrape Targets
Before booting, edit `./prometheus.yml` (create it if missing) to define what Prometheus should monitor. A bare-minimum example watching itself:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```
*(You will eventually add targets like `node_exporter:9100` to this file).*

### 2. Boot the Stack
```bash
docker compose up -d
```

### 3. Connect Grafana to Prometheus
1. Open your browser and go to `http://<server-ip>:3000`.
2. Login with the default credentials: `admin` / `admin` (You will be forced to change this immediately).
3. In the left sidebar, go to **Connections -> Data Sources** and click "Add data source".
4. Select **Prometheus**.
5. Under HTTP URL, enter `http://prometheus:9090` (We use the Docker service name, not localhost).
6. Scroll down and click **Save & Test**.

### 4. Import a Dashboard
To visualize hardware metrics, install `node-exporter` on your server, point Prometheus to it, then go to Grafana -> Dashboards -> Import, and type ID `1860` (Node Exporter Full).