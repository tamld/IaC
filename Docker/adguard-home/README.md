<div align="center">
  <img src="https://cdn.rawgit.com/AdguardTeam/AdGuardHome/master/scripts/favicon/apple-touch-icon.png" width="100" />
  
  # AdGuard Home
  **Network-wide Ads & Trackers Blocking DNS Server**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/adguard/adguardhome)](https://hub.docker.com/r/adguard/adguardhome)
</div>

---

## 🛡️ What is AdGuard Home?

AdGuard Home is a network-wide software for blocking ads & tracking. After you set it up, it'll cover **all your home devices**, and you don't need any client-side software for that. 

It operates as a DNS server that re-routes tracking domains to a "black hole", thereby preventing your devices from connecting to those servers.

### ✨ Key Features
- **Network-wide Blocking:** Stops ads and trackers on Smart TVs, IoT devices, smartphones, and computers.
- **Parental Control:** Safely block adult content and enforce 'Safe Search' on Google/Bing.
- **DNS Rewrite (Homelab Routing):** Extremely useful for self-hosters to route internal traffic (e.g., `app.home.lan`) to internal IP addresses.
- **Detailed Analytics:** Web UI provides granular Query Logs and Top Clients statistics.
- **Encrypted DNS:** Supports DNS-over-HTTPS (DoH), DNS-over-TLS (DoT), and DNS-over-QUIC (DoQ).

---

## ⚙️ Architecture & Compose Configuration

This stack is configured to run out-of-the-box with persistent configurations. 

### Port Bindings
- `53:53/udp` - Standard DNS query routing (UDP).
- `53:53/tcp` - Standard DNS query routing (TCP).
- `3000:3000/tcp` - The port used for the initial setup wizard and the Web Management panel. 

### Persistent Volumes
- `./workdir` -> Contains running state, query logs, and customized filters.
- `./confdir` -> Holds the primary `AdGuardHome.yaml` configuration file.

---

## 🚀 Getting Started

### 1. Pre-requisites
Ensure that **Port 53** is not being used by the host OS. On Ubuntu, `systemd-resolved` usually binds to port 53. To free it up, edit `/etc/systemd/resolved.conf`:
```ini
[Resolve]
DNS=1.1.1.1
DNSStubListener=no
```
Then restart the service: `sudo systemctl restart systemd-resolved`.

### 2. Startup
Navigate to this directory and start the container in detached mode:
```bash
docker compose up -d
```

### 3. Initial Configuration Wizard
1. Open your web browser and go to `http://<your-server-ip>:3000`.
2. Keep the **Admin Web Interface** on port `3000` (or `80` if you don't use another reverse proxy, though port `3000` avoids conflicts).
3. Set the **DNS server** listening port to `53`.
4. Create your administrator account.
5. Finish the setup. Future accesses to the dashboard will be on the port you selected for the Admin Web Interface.

---

## 💡 Best Practices for Self-Hosting

- **Upstream DNS:** By default, AdGuard uses its own DNS. For privacy and speed, go to *Settings -> DNS Settings* and add Cloudflare (`https://dns.cloudflare.com/dns-query`) or Quad9 (`tls://dns.quad9.net`).
- **Homelab DNS Rewrites:** If you host applications locally, go to *Filters -> DNS rewrites*. Add `example.com` aiming to your Reverse Proxy IP (e.g. Traefik/Caddy). This loops traffic locally, ensuring LAN speeds instead of hitting the external internet!