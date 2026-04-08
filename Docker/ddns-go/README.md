<div align="center">
  <img src="https://raw.githubusercontent.com/jeessy2/ddns-go/master/docs/logo.png" width="120" />
  
  # DDNS-Go
  **Simple, Lightweight Dynamic DNS Updater**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/jeessy/ddns-go)](https://hub.docker.com/r/jeessy/ddns-go)
</div>

---

## 🌐 What is DDNS-Go?

DDNS-Go is a dynamic DNS updater utility written in Golang. For home-labbers whose Internet Service Providers constantly rotate their public IP address, DDNS-Go detects the change and pushes the new IP to a domain registrar (like Cloudflare).

### ✨ Key Features
- **Extensive Provider Support:** Natively supports Cloudflare, AWS Route 53, Namecheap, GoDaddy, Aliyun, Huawei Cloud, Tencent Cloud, and custom Webhooks.
- **Dual Stack Support:** Reliably queries and updates both IPv4 and IPv6 simultaneously.
- **Clean UI:** Configuration is done entirely through an intuitive web interface rather than complex JSON/YAML files.
- **Webhook Capabilities:** Configure Slack, Discord, or Telegram alerts when your IP changes.
- **High Performance:** Minimal RAM/CPU footprint due to its compiled Go architecture.

---

## ⚙️ Architecture & Compose Configuration

This container runs in **host network mode** to ensure it can accurately read the raw networking interfaces of the host server without being NAT'd by Docker's internal networking.

### Network Settings
- `network_mode: host` -> Port `9876` will be opened directly on the server host.

### Persistent Volumes
- `./data:/root` -> Persists the DDNS-Go UI configuration state (`.ddns_go.yaml`) so API keys are not lost upon container destruction.

---

## 🚀 Getting Started

### 1. Pre-requisites
Ensure port `9876` is available on the machine running this container. Also, acquire the API Key or Token from your DNS Registrar (e.g. Cloudflare API Token restricted to Zone DNS Edit).

### 2. Startup
```bash
docker compose up -d
```

### 3. Web UI Configuration
1. Navigate to: `http://<your-server-ip>:9876`.
2. **Select DNS Provider:** Choose your provider (e.g. Cloudflare) and enter your API Token.
3. **Configure Domains:** Specify the Subdomains/Root Domains you want updated. Separate multiple domains by commas.
4. **Choose Retrieval Strategy:** Tell DDNS-Go how to figure out your IP. (Options: Through an interface like `eth0` or querying a public echo service like `api.ipify.org`).
5. **Set Authentication:** Under the 'Security' section, set a Username and Password. By default, the port is open to anyone on the network.
6. Click **Save**.

### 4. Verification
Check the right-side panel on the dashboard. You should immediately see log lines confirming:
`Update successful for domain: mydomain.com (IP: 198.xxx.xxx.xxx)`.