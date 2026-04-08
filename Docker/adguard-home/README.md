<div align="center">

<pre>
   _____       .___Guard
  /  _  \    __| _/________  __  _____ _______  
 /  /_\  \  / __ |/ ___\  |/  /_\__  \\_  __ \ 
/    |    \/ /_/ / /_/  >    <  / __ \|  | \/ 
\____|__  /\____ \___  /__|_  \(____  /__|    
        \/      \/_____/    \/      \/        
</pre>

# AdGuard Home: Enterprise DNS Shield

[![Security](https://img.shields.io/badge/Security-Hardened-green?style=for-the-badge&logo=springsecurity&logoColor=white)](#)

*Stop feeding your bandwidth to trackers and ads. Take back your network.*

</div>

---

## 🛑 The Internet is Leaking Your Data.

**Problem:** Every single device in your home or office is silently phoning home. Smart TVs, IoT cameras, and mobile apps are leaking telemetry data and downloading malicious trackers without your consent. 
**Solution:** **AdGuard Home**. A network-wide ad-and-tracker blocking DNS server that acts as a blackhole for malicious domains.

---

## 🗺️ ASCII Architecture Flow
*Why ASCII? Because markdown renderers break, but raw text is eternal. This shows exactly how DNS traffic routes through your network.*

```text
 [ LAN Clients ]
 (Phones, TVs, Laptops)
       |
       | (DNS Request Port 53)
       v
+------------------------+      (Matches Adlist?)
|   AdGuard Home DNS     | ----------------------> [ BLACKHOLE / DROP ]
+------------------------+
       | (If Safe)
       | (DoH / DoT)
       v
+------------------------+
|  Upstream Providers    | (Cloudflare, Quad9)
+------------------------+
       |
       v
  [ Internet ]
```

---

## 🛤️ The First-Time User Workflow
A new user must understand the sequence of taking control of their DNS. Here is the operational workflow from zero to deployed:

1. **Phase 1: The Prerequisites**
   - A static IP dedicated to your server.
   - Ensure port `53` (TCP/UDP) is not blocked by your router or hijacked by systemd-resolved (common in Ubuntu).

2. **Phase 2: The Boot**
   Deploy the Docker stack:
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Setup Wizard**
   Open your browser to `http://<server-ip>:3000`. You will be greeted by the installation tool. 
   - *Crucial Step*: Set the web interface to port `80` (or `3000` if behind proxy) and the DNS server to listen on port `53`.

4. **Phase 4: Network Takeover**
   Go to your physical router's Admin Panel. Change the main DHCP DNS Server to point to `your-server-ip`. Now, every device on your Wi-Fi automatically uses AdGuard.

---

## 📊 Expected Outcomes
- **Bandwidth**: Saves up to 20% of network traffic.
- **Speed**: Faster page loads due to zero-latency caching.
- **Security**: Prevents phishing domains from resolving.
