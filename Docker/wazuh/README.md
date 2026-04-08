<div align="center">
  <img src="https://wazuh.com/uploads/2019/12/wazuh-logo-2.svg" width="200" />
  
  # Wazuh
  **Open Source SIEM and XDR Security Platform**

  [![Wazuh Docs](https://img.shields.io/badge/docs-wazuh.com-blue)](https://documentation.wazuh.com/)
</div>

---

## 🛡️ What is Wazuh?

Wazuh is a free, open-source, and enterprise-ready security monitoring solution for threat detection, integrity monitoring, incident response, and continuous compliance. It helps you gain deep visibility into your endpoints and servers.

### ✨ Key Features
- **Security Information & Event Management (SIEM):** Centralizes and analyzes logs from across your infrastructure.
- **Endpoint Detection and Response (EDR):** The Wazuh agent actively monitors file integrity, processes, and network connections.
- **Vulnerability Detection:** Cross-references software installed on your endpoints against the National Vulnerability Database (NVD).
- **Active Response:** Not just a monitor—it can automatically execute scripts (like blocking an IP in `iptables`) when malicious behavior is detected.
- **Regulatory Compliance Auditing:** Out-of-the-box dashboards for PCI DSS, GDPR, HIPAA, and NIST.

---

## ⚙️ Architecture & Compose Configuration

This stack deploys the minimal Wazuh environment: the Manager processing nodes and the Web Dashboard. *(Note: Full production deployments typically include a dedicated Elasticsearch/OpenSearch cluster configured separately).*

### Port Bindings
**Wazuh Manager:**
- `1514:1514` - Agent communication port (TCP).
- `1515:1515` - Agent enrollment port (TCP).
- `55000:55000` - RESTful API port.
- `514:514/udp` - Standard Syslog ingestion port.

**Wazuh Dashboard:**
- `443:5601` - Exposes the internal Kibana/OpenSearch Dashboards port 5601 securely via `443`.

---

## 🚀 Getting Started

### 1. Requirements
Security Information Management involves heavy indexing. Your host server should have a minimum of **4GB to 8GB of RAM**. Deploying on smaller droplets will result in Elasticsearch crash-loops (OOM kills).

### 2. Boot the Stack
Ensure you have SSL certificates or use a Reverse Proxy to terminate HTTPS.
```bash
docker compose up -d
```
*Note: Wazuh takes roughly 2-3 minutes to initialize its internal databases and sync rule feeds successfully before the dashboard becomes fully responsive.*

### 3. Deploy an Agent
1. Open up a browser and navigate to `https://<your-server-ip>`.
2. Login with the default credentials provided in the official documentation (Usually `admin / SecretPassword`, **Change immediately!**).
3. Click "Add agent".
4. Follow the Wizard to select your target OS (Windows, Linux, macOS). It will generate an exact CLI command.
5. Paste the CLI command into your target server. Start the agent using `systemctl start wazuh-agent`.
6. Return to the Dashboard; the agent will appear and begin streaming logs and vulnerability scans.