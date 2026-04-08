<div align="center">

<pre>
__        _______   _____                 
\ \      / / ____| |  ___|__ _ ___ _   _  
 \ \ /\ / /|  _|   | |_ / _` / __| | | | 
  \ V  V / | |___  |  _| (_| \__ \ |_| | 
   \_/\_/  |_____| |_|  \__,_|___/\__, | 
                                  |___/  
</pre>

# WireGuard Easy: Zero-Config VPN

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)

*Access your homelab from anywhere. Without a PhD in networking.*

</div>

---

## 🛑 Traditional VPNs are Unnecessarily Complex.

**Problem:** You want access to your internal Pi-Hole or private file servers from a coffee shop. But setting up IPSec networks requires editing messy `.ovpn` files, and praying the routing engine doesn't break.
**Solution:** **WG-Easy**. It takes the fast, state-of-the-art WireGuard kernel module and wraps it in a beautiful, simple Web UI. Create a client, scan a QR code with your phone, and you are securely tunneled home.

---

## 🗺️ ASCII Architecture Flow
*See how UDP packets tunnel through your firewall back to your home network.*

```text
[ Remote Laptop / Phone ]
          |
          | (Encrypted UDP Packets)
          |
          v
+-------------------------------+      [ Home Router ]
| Public Internet IP :51820     | ---> (Port Forward UDP 51820)
+-------------------------------+             |
                                              v
                                   +-----------------------+
                                   |  WG-Easy Docker App   |
                                   | (Decrypts inside WG0) |
                                   +-----------------------+
                                              |
                                              v
                              +-------------------------------+
                              |    Internal Home Network      |
                              |   (Pi-Hole, DBs, NAS, etc)    |
                              +-------------------------------+
```

---

## 🛤️ The First-Time User Workflow
Wireguard needs intimate access to your host's networking kernel to work natively.

1. **Phase 1: The Core Prerequisite**
   Your server **MUST** have a public, resolvable IP or a DDNS name so your roaming laptop can find it. You must also configure your physical router to port-forward `51820 UDP` to this server machine.

2. **Phase 2: Environmental Anchoring**
   Open `.env`. Ensure `WG_HOST` is set to your public IP or DDNS domain. Set a strong `PASSWORD` for the Web UI.

3. **Phase 3: Kernel Privileges**
   Start the stack.
   ```bash
   docker compose up -d
   ```
   *Note: WG-Easy needs `cap_add: NET_ADMIN` and `SYS_MODULE` privileges. It modifies your host's routing tables natively for bare-metal speeds.*

4. **Phase 4: QR-Code Tunneling**
   Access `http://<ip>:51821`. Enter your password. Click "Add Client", name it "My iPhone", and click the QR code icon. Open the Wireguard app on your phone, scan it, and flick the switch. You are now tunneled. 

---