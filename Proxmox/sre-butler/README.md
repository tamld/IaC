# Proxmox SRE Butler — SRE Butler Deployment Specs

- **Persona Name**: **SRE Butler** (Homelab SRE Butler Daemon)
- **Hierarchy**: Orchestrator (Antigravity Orchestrator) ⇄ SRE Butler (In-situ SRE Daemon)
- **Container Target**: `SRE_BUTLER` (`svc-butler` — `192.168.1.29`)
- **Systemd Unit**: `/etc/systemd/system/homelab-butler.service`
- **Memory Footprint**: ~18.1MB RAM (Capped at 256MB)
- **Central Telemetry Integrations**:
  - VictoriaLogs (`VICTORIALOGS:9428`) LogSQL Stream & 60s Watchdog
  - Uptime Kuma (`UPTIME_KUMA`) Instant Incident Webhook (`:8080/webhook/kuma`)
  - Proxmox Hypervisor Metrics (`pvesh get nodes/pve/lxc`)
  - CrowdSec LAPI (`CROWDSEC`) Autonomous Quarantine Engine
- **Quality & Verification**: 20/20 Test Cases Passed (100%) across Telemetry, Auto-Heal, Security, EventBus, and SRE AI Brain.
