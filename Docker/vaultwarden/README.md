<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/1/14/Bitwarden_logo.svg" width="100" />
  
  # Vaultwarden
  **Unofficial Bitwarden Compatible Password Manager**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/vaultwarden/server)](https://hub.docker.com/r/vaultwarden/server)
</div>

---

## 🔐 What is Vaultwarden?

Vaultwarden is an alternative implementation of the Bitwarden server API written entirely in Rust. It is fully compatible with official Bitwarden clients (Desktop, Web, Mobile, and Browser Extensions) but consumes significantly fewer resources, making it ideal for self-hosted homelab deployments.

### ✨ Key Features
- **Ultra Lightweight:** Uses ~15MB of RAM compared to the gigabytes required by the official MSSQL/C# container stack.
- **Client Compatibility:** Works natively with all official Bitwarden apps.
- **Organization Support:** Complete support for Vault Organizations, Collections, and password sharing constraints.
- **Bitwarden Send:** Securely share text or files via ephemeral, self-destructing links.
- **Integrated Admin Panel:** Built-in web portal to manage registered users and system diagnostics.

---

## ⚙️ Architecture & Compose Configuration

This stack is configured strictly for edge-security. It exposes **zero ports** to the host machine. Instead, it relies on being placed behind an existing reverse proxy.

### Network Settings
- `proxy` (External Network) -> Vaultwarden joins an external Docker bridged network named `proxy`. Your reverse proxy (like [Traefik](../traefik) or [Caddy](../caddy)) must also be on this network to route traffic to Vaultwarden.

### Environment & Security
- `SIGNUPS_ALLOWED=false` -> Hardcoded to `false`. Outsiders cannot register accounts on your instance. Registration must be done by invitation via the Admin panel.
- `WEBSOCKET_ENABLED=true` -> Enables real-time syncing of passwords across devices without manual refreshes.
- `ADMIN_TOKEN` -> A highly secure token used exclusively to access the web-based Administrator Panel.

### Persistent Volumes
- `./vw-data` -> Stores the internal SQLite database, RSA keys, and attachments.

---

## 🚀 Getting Started

### 1. Pre-requisites
Vaultwarden **requires HTTPS** to function securely. Modern browsers and the Bitwarden extension will refuse to send credentials over plain HTTP. You must set up a reverse proxy with Let's Encrypt certificates before starting this container.

Ensure the `proxy` network exists:
```bash
docker network create proxy
```

### 2. Configure the Admin Token
Use `openssl rand -base64 48` to generate a secure string.
Copy `.env.example` to `.env` and paste it:
```env
ADMIN_TOKEN=your_secure_base64_string_here
```

### 3. Boot the Server
```bash
docker compose up -d
```

### 4. Admin Setup & User Invitation
1. Go to `https://vault.yourdomain.com/admin` and log in with your `ADMIN_TOKEN`.
2. Under "Users", invite your personal email address.
3. Check the Vaultwarden logs or configure SMTP to extract the invitation link, and register your official account.

---

## 💡 Reverse Proxy Tips

If using **Caddy**, your routing block is incredibly simple:
```caddyfile
vault.yourdomain.com {
    reverse_proxy vaultwarden:80
}
```
*(Caddy automatically handles Websocket upgrading, meaning `WEBSOCKET_ENABLED=true` requires no extra configuration on the proxy level).*