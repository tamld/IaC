<div align="center">
  <img src="https://raw.githubusercontent.com/greenbone/gsa/main/public/img/greenbone-logo.png" width="200" />
  
  # Greenbone (OpenVAS)
  **Network Vulnerability Management Software**
</div>

---

## 🔍 What is Greenbone?

Greenbone Security Assistant (GSA) is the web interface for the Greenbone Vulnerability Management (GVM) framework, originally known as OpenVAS. It is the premier open-source tool for performing detailed network scans to discover known security vulnerabilities on your servers, databases, and network devices.

### ✨ Key Features
- **Network Vulnerability Tests (NVTs):** Daily updated feeds containing tens of thousands of vulnerability signatures.
- **Asset Discovery:** Identifies hosts, operating systems, and open ports across your subnet.
- **Reporting & Compliance:** Generates detailed PDF/XML reports highlighting CVSS threat scores and actionable remediation steps.
- **Scheduled Scanning:** Automatically audit your infrastructure weekly/monthly to catch novel CVEs.

---

## ⚙️ Architecture & Compose Configuration

**Important Note:** The provided `docker-compose` file spins up the `greenbone/gsa` (Greenbone Security Assistant) container, which serves the frontend web interface. A complete, fully functional scanning infrastructure requires additional backend components (such as `gvmd`, `ospd-openvas`, `mqtt-broker`, `redis`, and `postgres`). This compose file serves as a starting point to run the frontend UI.

### Port Bindings
- `9392:80` - The Greenbone Security Assistant HTTP interface.

---

## 🚀 Getting Started

If you plan to run the full OpenVAS suite using community containers:

### 1. Startup
```bash
docker compose up -d
```

### 2. The Sync Process
A full Greenbone deployment must synchronize vulnerability feeds (SCAP, CERT, NVT) from Greenbone servers before the first scan can occur. This initial sync is heavily reliant on CPU and internet bandwidth, sometimes taking up to 30-45 minutes. Attempting to scan before the feeds are hydrated will result in empty reports.

### 3. Usage
1. Open your browser to `http://<your-server-ip>:9392`.
2. Login to the console.
3. Go to **Configuration -> Targets** to define an IP address or subnet (e.g., `192.168.1.0/24`).
4. Go to **Scans -> Tasks**, create a new task using your Target, and execute it.
5. Review the resulting Reports dashboard to identify Critical, High, and Medium vulnerabilities affecting your network.