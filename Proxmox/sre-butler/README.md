# 🥭 Autonomous SRE Butler & Adaptive Threat Intelligence Engine

> **Zero-Root, Event-Driven In-Situ SRE Daemon and Adaptive CTI Defense for Proxmox Homelabs.**

---

## 📌 Architecture Overview

The **Autonomous SRE Butler** pattern transforms reactive homelab maintenance into an intelligent, closed-loop resilience system:

1. **Dual-Loop Health Monitoring**:
   * **Fast Loop (60s)**: Probes internal compute health and container running states via Proxmox REST API using least-privilege tokens.
   * **Reactive Ingress**: Receives webhook incident alerts from Uptime Kuma and live logs.
2. **Adaptive Threat Intelligence (CTI Watchdog)**:
   * Periodically ingests trusted threat streams (CISA KEV, GitHub Advisory, OSV.dev, FIRST EPSS).
   * Caches HTTP 304 ETags in local SQLite to maintain zero token waste.
   * Deterministic $O(1)$ SBOM matching against local service catalog.
   * Retroactive LogSQL forensic queries to VictoriaLogs to detect if an exploit path was probed in the past 30 days.
3. **Human-in-the-Loop (HITL) Safety Gate**:
   * Generates interactive Telegram proposal cards signed with **HMAC-SHA256 (300s TTL)**.
   * Critical IAM and protected services can NEVER be modified without human operator cryptographic sign-off.

---

## 🚀 Quickstart

1. **Configure Environment**:
   ```bash
   cp .env.example .env
   # Edit .env and supply your endpoints and HMAC secret
   ```

2. **Supply your Homelab SBOM**:
   ```bash
   cp config/sbom.json.example config/sbom.json
   # Define your container inventory, package versions, and exposure flags
   ```

3. **Run Verification**:
   ```bash
   python threat_engine.py
   ```

4. **Install as Systemd Service**:
   ```ini
   [Unit]
   Description=Autonomous Homelab SRE Butler Daemon
   After=network.target

   [Service]
   Type=simple
   User=butler
   WorkingDirectory=/opt/butler
   ExecStart=/opt/butler/venv/bin/python threat_engine.py
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target
   ```
