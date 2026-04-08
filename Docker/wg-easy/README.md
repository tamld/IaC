<div align="center">
  <img src="https://raw.githubusercontent.com/wg-easy/wg-easy/master/assets/logo.png" width="120" />
  
  # WireGuard Easy
  **The Easiest Way to Install & Manage WireGuard VPN**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/weejewel/wg-easy)](https://hub.docker.com/r/weejewel/wg-easy)
</div>

---

## 🔒 What is WireGuard Easy?

WireGuard is an extremely fast and modern VPN tunnel. However, configuring `wg0.conf` manually and generating public/private keys using the CLI is tedious and error-prone. 

`wg-easy` solves this by delivering an all-in-one container containing a WireGuard engine alongside an incredibly clean, beautiful Web UI to manage clients visually.

### ✨ Key Features
- **One-Click Client Generation:** Create a new VPN client profile with a single click.
- **Mobile QR Codes:** Scan a QR code directly from the Web UI to instantly configure your phone securely.
- **Auto-Download Configs:** Output `.conf` files ready to be imported into any laptop or router.
- **Live Connection Stats:** Monitor exactly which clients are currently connected and how much data they have transferred.

---

## ⚙️ Architecture & Compose Configuration

WireGuard operates at the kernel level for maximum performance, which necessitates granting specific Linux capabilities and modifying networking properties.

### Privileged Host Capabilities
- `cap_add: NET_ADMIN, SYS_MODULE` - Essential to allow the container to manipulate the host network stack and mount the wireguard kernel module.
- `sysctls: net.ipv4.ip_forward=1` - Required to allow traffic entering the VPN to be forwarded (routed) out to the internet or into your local LAN.

### Port Bindings
- `51820:51820/udp` - The actual WireGuard tunnel port. (Firewall Must Allow UDP!).
- `51821:51821/tcp` - The Web Management UI.

### Persistent Volumes
- `~/.wg-easy:/etc/wireguard` -> Stores the internal database and generated configurations. Note: This saves to the home directory of the user executing the `docker compose` command, not the local folder!

---

## 🚀 Getting Started

### 1. Configure the Environment
Ensure your `.env` contains the required information:
```env
WG_HOST=vpn.yourdomain.com      # Ensure this resolves to your Public IP
WEB_PASSWORD=supersecurepassword # Used to log into the Dashboard at port 51821
```
*(If `WG_HOST` is left blank or inaccurate, the `.conf` files generated for clients will point to the wrong destination and won't connect).*

### 2. Boot the VPN
```bash
docker compose up -d
```

### 3. Open your Firewall
Ensure your cloud provider (AWS/DigitalOcean/Hetzner) or your hardware Router has **UDP Port 51820** exposed. A common pitfall is only opening it for TCP. WireGuard exclusively uses UDP.

### 4. Create your first Client
Head to `http://<your-server-ip>:51821`. Enter your `WEB_PASSWORD` and click "+ New Client".