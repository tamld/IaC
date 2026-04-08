<div align="center">

<pre>
  ___  ___  _  _ ___      ___      
 |   \|   \| \| / __|___ / __|___  
 | |) | |) | .` \__ \___| (_ / _ \ 
 |___/|___/|_|\_|___/    \___\___/ 
</pre>

# DDNS-Go: The Ultimate Dynamic DNS Updater

[![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](#)

*Never lose access to your home lab when your ISP rotates your IP address.*

</div>

---

## 🛑 Home Servers Disappear Without Warning.

**Problem:** Most home internet connections use dynamic IPs. Every time your ISP resets your modem, your home network gets a new IP address, breaking all your external domains and tunnels.
**Solution:** **DDNS-Go**. A lightweight, multi-provider automated Dynamic DNS client. It constantly monitors your public IP and immediately updates your DNS records at Cloudflare, AliYun, or AWS Route53.

---

## 🗺️ ASCII Architecture Flow
*How your domain name stays anchored to a shifting home IP.*

```text
                            (1. Get IP)    +-------------------+
                          +--------------> |   ipify.org       |
                          |                +-------------------+
                          |                  | (Returns 1.2.3.4)
+-------------------+     |                  v
| Home ISP Router   |     |    +------------------------+
| (IP Randomly      | -------- |   DDNS-Go Container    |
|  Changes)         |          +------------------------+
+-------------------+                    |
                                         | (2. Push new IP)
                                         v
                               +-------------------+
                               | Cloudflare / AWS  |
                               | (DNS Registrar)   |
                               +-------------------+
```

---

## 🛤️ The First-Time User Workflow
Setting up DDNS requires careful coordination with your DNS provider.

1. **Phase 1: The Prerequisites**
   - A registered domain name on supported providers (Cloudflare, AWS Route53, Namecheap).
   - An API Token from your DNS provider with permissions to **EDIT Zone DNS Records**.

2. **Phase 2: Deployment**
   Start the DDNS-Go core:
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Binding**
   - Access the Web UI at `http://<your-server>:9876`.
   - Select your provider (e.g., Cloudflare) and paste your API Token.
   - In the `Domains` block, type exactly which subdomains to update (pattern: `*.yourdomain.com`).

4. **Phase 4: Verification**
   Hit `Save`. Check the DDNS-Go logs. You should see `[Success] IPv4 updated to 1.2.3.X`. Your home-lab is now resilient to ISP changes.

---

## 📊 Supported Platforms
- Cloudflare, AWS Route53, Tencent, Namecheap, GoDaddy, Aliyun.
- Webhook notifications via Slack / Telegram.
