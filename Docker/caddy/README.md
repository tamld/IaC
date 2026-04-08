<div align="center">

<pre>
  ____          _     _       
 / ___|__ _  __| | __| |_   _ 
| |   / _` |/ _` |/ _` | | | |
| |__| (_| | (_| | (_| | |_| |
 \____\__,_|\__,_|\__,_|\__, |
                        |___/ 
</pre>

# Caddy: The Automatic HTTPS Proxy 

[![Nginx Alternative](https://img.shields.io/badge/Proxy-Caddy-00ADD8?style=for-the-badge&logo=caddy&logoColor=white)](#)

*Route your traffic and secure it with Auto-TLS — without manual certificates.*

</div>

---

## 🛑 Stop Wasting Time on SSL Certificates.

**Problem:** Renewing Let's Encrypt certificates manually via Certbot or wrestling with 500-line Nginx configurations is tedious and error-prone.
**Solution:** **Caddy**. A powerful, enterprise-ready reverse proxy that provisions and renews TLS certificates *automatically* by default. Just point the domain to Caddy and let it handle the rest.

---

## 🗺️ ASCII Architecture Flow
*A raw text visualization of how Caddy automates trust in your infrastructure.*

```text
                 +-------------------+
                 |   Let's Encrypt   |
                 +-------------------+
                          | (Auto Fetches Certs)
                          v
                    +-----------+
[ Internet ] -----> |  CADDY    | (Listens on 80/443)
                    +-----------+
                          |
            +-------------+-------------+
            |             |             |
            v             v             v
      +---------+   +---------+   +---------+
      |  App 1  |   |  App 2  |   |  API    | 
      | (:8080) |   | (:3000) |   | (:5000) |
      +---------+   +---------+   +---------+
```

---

## 🛤️ The First-Time User Workflow
How do you actually use this without tearing your hair out? Here is the blueprint.

1. **Phase 1: The Prerequisites**
   - You **MUST** own a domain name (e.g., `app.domain.com`).
   - You **MUST** ensure ports `80` and `443` are port-forwarded on your router to this server.
   - Your DNS A-record must point to your server's Public IP.

2. **Phase 2: The Rules (Caddyfile)**
   Open your `Caddyfile`. All it takes is three lines:
   ```caddyfile
   app.domain.com {
     reverse_proxy app_container:8080
   }
   ```

3. **Phase 3: The Ignition**
   Start the stack:
   ```bash
   docker compose up -d
   ```

4. **Phase 4: The Validation**
   Wait 30 seconds. Caddy will notice the new domain, automatically talk to Let's Encrypt to prove domain ownership via ACME HTTP-01 challenge, download the certificate, and reload routing.
   Visit `https://app.domain.com`. You are now secure.

---

## 📊 Why Caddy Over Nginx?
| Feature | Nginx / Traefik | Caddy |
|---------|-----------------|-------|
| **HTTPS** | Manual Certbot | **100% Automatic** |
| **Config**| Complex / Verbose | Typically < 5 lines |
