<div align="center">

<pre>
  ___                    __  _____    ____  
 / _ \ _ __   ___ _ __ |  \/  \ \  / / __ \ 
| | | | '_ \ / _ \ '_ \| \  / |\ \/ / /__\ \
| |_| | |_) |  __/ | | | |\/| | \  / /____\ \
 \___/| .__/ \___|_| |_|_|  |_|  \/ /______/
      |_|                                   
</pre>

# Greenbone OpenVAS: Enterprise Vulnerability Scanner

[![Security](https://img.shields.io/badge/Security-Scanner-green?style=for-the-badge&logo=springsecurity&logoColor=white)](#)

*Ignorance is not a defense against zero-days. Audit your infrastructure before they do.*

</div>

---

## 🛑 The Blind Spot in Your Infrastructure.

**Problem:** Do you actually know how many CVEs exist on your network right now? A single outdated dependency or an exposed RDP port is all an attacker needs.
**Solution:** **Greenbone Vulnerability Management (OpenVAS)**. A complete enterprise vulnerability scanning engine that identifies security holes, scores them by severity, and gives you exact remediation steps.

---

## 🗺️ ASCII Architecture Flow
*An internal look into the massive engine powering the vulnerability audits.*

```text
+-----------------------+       (HTTP UI)
|  Greenbone Assistant  | <----------------- [ Security Admin ]
+-----------------------+
           |
           v
+-----------------------+       (Sync Jobs)      +-----------------+
|   Greenbone Manager   | <--------------------> |  NVT Feed Sync  |
|   (GVMD Daemon)       |                        +-----------------+
+-----------------------+
           |
           v
+-----------------------+      (Port Scans)      +-----------------+
|   OSPD OpenVAS        | ---------------------> |  Target LAN/WAN |
|   Scanner Core        |      (Exploit Checks)  +-----------------+
+-----------------------+
           |
           v
+-----------------------+
|  PostgreSQL / Redis   | (Stores CVE Data & Reports)
+-----------------------+
```

---

## 🛤️ The First-Time User Workflow
OpenVAS is an enterprise behemoth. Do not rush the startup process.

1. **Phase 1: Memory & Feed Sizing**
   Before running anything, know that Greenbone requires **Heavy RAM (4GB+)** because it loads thousands of vulnerability signatures (NVTs) into cache.

2. **Phase 2: The Boot & The Wait**
   Start the stack:
   ```bash
   docker compose up -d
   ```
   **CRITICAL:** You cannot use OpenVAS immediately. The `greenbone-feed-sync` container is now downloading gigabytes of CVE definitions via rsync. *This will take 15 to 45 minutes.* Monitor it using `docker logs -f greenbone-feed-sync`.

3. **Phase 3: The Target Matrix**
   Once CPU usage settles, access `http://<your-ip>:9392`.
   - Go to `Configuration -> Targets`. Create a target representing your home subnet (e.g., `192.168.1.0/24`).

4. **Phase 4: Launch the Audit**
   - Go to `Scans -> Tasks` -> Create. Use the "Full and Fast" profile against your target. Your network is now being actively interrogated.
---