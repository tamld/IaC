<div align="center">

<pre>
 __  __             _ _             
|  \/  | ___  _ __ (_) |_ ___  _ __ 
| |\/| |/ _ \| '_ \| | __/ _ \| '__|
| |  | | (_) | | | | | || (_) | |   
|_|  |_|\___/|_| |_|_|\__\___/|_|   
                                    
</pre>

# Monitor: The Omniscient Eye (Prometheus + Grafana)

[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](#)

*Don't guess why the server crashed. Prove it.*

</div>

---

## 🛑 Flying Blind in Production.

**Problem:** When a server goes down, you SSH into the server, run `htop`, and hunt blindly for spikes that happened 20 minutes ago.
**Solution:** **The Monitoring Stack (Prometheus + Grafana)**. A world-class observability pipeline. Prometheus persistently scrapes every metric, and Grafana transforms it into interactive visual dashboards.

---

## 🗺️ ASCII Architecture Flow
*Observe how telemetry flows from your raw hardware to the visual dashboards.*

```text
    [ Docker Containers ]        [ Host OS Systems ]
            | (cAdvisor)                | (Node Exporter)
            v                           v
+---------------------------------------------------+
|               METRICS ENDPOINTS (:9100)           |
+---------------------------------------------------+
                          | (Prometheus Scrapes every 15s)
                          v
               +----------------------+
               |  Prometheus Server   | (Stores Time-Series DB)
               +----------------------+
                          | (PromQL Queries)
                          v
               +----------------------+
               | Grafana Visualization| 
               +----------------------+
                          |
             [ Beautiful Web Dashboards ]
```

---

## 🛤️ The First-Time User Workflow
Observability takes a few steps to wire up. Here is how you jumpstart your metrics:

1. **Phase 1: The Scrape Targets**
   Metrics do not appear magically. You must tell Prometheus where to look. Open `prometheus.yml` and explicitly define your endpoint IPs (e.g., `192.168.1.50:9100` for Node Exporter).

2. **Phase 2: Ignite the Stack**
   Bring up the engine:
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Grafana Binding**
   Open `http://<your-ip>:3000`. Login with default `admin/admin` (and change it immediately).
   - Go to `Connections > Data Sources` -> Add `Prometheus`. 
   - Write the internal docker URL: `http://prometheus:9090`. Save and Test.

4. **Phase 4: The Dashboard Import**
   No need to build charts from scratch! Go to Dashboards -> Import.
   - Enter ID `1860` for the ultimate Linux Node Dashboard.
   - Enter ID `14282` for global cAdvisor Docker metrics. You are now omniscient.

---