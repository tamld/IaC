<div align="center">
  <img src="https://caddyserver.com/resources/images/caddy-logo.svg" width="150" />
  
  # Caddy
  **The Ultimate Event-Driven Web Server with Automatic HTTPS**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/caddy)](https://hub.docker.com/_/caddy)
</div>

---

## 🌩️ What is Caddy?

Caddy is a powerful, enterprise-grade open-source web server with automatic HTTPS written in Go. It instantly obtains and renews TLS certificates for your sites without manual configuration, making securing applications a developer's dream.

### ✨ Key Features
- **Automatic HTTPS by Default:** Automatically provisions certificates via Let's Encrypt and ZeroSSL.
- **Zero Downtime Reloads:** Update your configuration and reload without dropping active connections.
- **Dead-simple Configuration:** The `Caddyfile` is human-readable, reducing proxy configs from 50 lines to 3 lines.
- **HTTP/3 & QUIC Support:** Built-in modern protocol support for maximum performance.
- **Static File & Reverse Proxy:** Handles both static sites and dynamic proxying elegantly.

---

## ⚙️ Architecture & Compose Configuration

This stack deploys Caddy mapped directly to the host's networking schema for inbound proxy handling.

### Port Bindings
- `80:80` - Required for HTTP traffic and ACME HTTP-01 challenge.
- `443:443` - Required for HTTPS web traffic.
- `443:443/udp` - Used for HTTP/3 over QUIC support.

### Persistent Volumes
- `./Caddyfile` -> Mounts the declarative configuration file into the container.
- `./site` -> The directory for hosting any static HTML/JS/CSS web files.
- `caddy_data` -> Docker named volume that securely persists Let's Encrypt certificates to avoid hitting rate limits on restart.
- `caddy_config` -> Stores autosave configurations.

### Networks
- `proxy` (External) -> Caddy connects to an external network called `proxy`. Target containers (like Git or CRM) must also join the `proxy` network so Caddy can reverse-proxy them by their container name.

---

## 🚀 Getting Started

### 1. Pre-requisites
Ensure ports `80` and `443` are completely free on your host node (no Apache or Nginx running). Create the external network if it doesn't exist:
```bash
docker network create proxy
```

### 2. Configure the Caddyfile
Open the `Caddyfile` in this directory (create it if missing) and define your routes:
```caddyfile
# Serve static files from the /srv volume
example.com {
    root * /srv
    file_server
}

# Reverse proxy an application located on the 'proxy' network
app.example.com {
    reverse_proxy my_container_name:3000
}
```

### 3. Start the Server
```bash
docker compose up -d
```

### 4. Zero-Downtime Reload Configuration
If you add or edit routes in the `Caddyfile` while Caddy is running, apply them without restarting:
```bash
docker compose exec -w /etc/caddy caddy caddy reload
```

---

## 💡 Troubleshooting
If a certificate fails to provision, verify that your DNS A-record correctly points to your server's IP address, and confirm that Port `80/443` are not blocked by a Cloud provider firewall (AWS security groups, Oracle ingress rules, etc).