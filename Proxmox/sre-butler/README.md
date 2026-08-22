# Proxmox SRE Butler — Xoài 🥭 Deployment Specs

- **Persona Name**: **Xoài 🥭** (Homelab SRE Butler Daemon)
- **Hierarchy**: Mít (Antigravity Orchestrator) ⇄ Xoài (In-situ SRE Daemon)
- **Container Target**: `CT121` (`svc-butler-prod` — `192.168.10.29`)
- **Systemd Unit**: `/etc/systemd/system/homelab-butler.service`
- **Memory Footprint**: ~18.1MB RAM (Capped at 256MB)
- **Central Telemetry Integrations**:
  - VictoriaLogs (`CT115:9428`) LogSQL Stream & 60s Watchdog
  - Uptime Kuma (`CT100`) Instant Incident Webhook (`:8080/webhook/kuma`)
  - Proxmox Hypervisor Metrics (`pvesh get nodes/pve/lxc`)
  - CrowdSec LAPI (`CT101`) Autonomous Quarantine Engine
- **Quality & Verification**: 20/20 Test Cases Passed (100%) across Telemetry, Auto-Heal, Security, EventBus, and SRE AI Brain.
