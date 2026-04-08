<div align="center">

<pre>
__     __          _ _                     _             
\ \   / /_ _ _   _| | |___      ____ _ _ __| | ___ _ __  
 \ \ / / _` | | | | | __\ \ /\ / / _` | '__| |/ _ \ '_ \ 
  \ V / (_| | |_| | | |_ \ V  V / (_| | |  | |  __/ | | |
   \_/ \__,_|\__,_|_|\__| \_/\_/ \__,_|_|  |_|\___|_| |_|
                                                         
</pre>

# Vaultwarden: The Ironclad Password Vault

[![Rust](https://img.shields.io/badge/Rust-F46623?style=for-the-badge&logo=rust&logoColor=white)](#)

*Stop trusting third parties with your root passwords. Host your own Bitwarden server.*

</div>

---

## 🛑 A Password Manager is Only as Secure as Where it Lives.

**Problem:** We all know we shouldn't reuse passwords. But paying to store the literal keys to your digital life on a third-party server requires absolute blind trust in their security team.
**Solution:** **Vaultwarden**. An alternative implementation of the Bitwarden server API written entirely in Rust. It requires barely 20MB of RAM and ensures you retain 100% custody of your cryptographic keys locally.

---

## 🗺️ ASCII Architecture Flow
*Observe Zero-Knowledge Encryption in raw text. Notice how the server never sees your actual password.*

```text
[ Browser / Phone App ]
          |
    (You type Master Password)
          |
          v
+-------------------------------+
|  Client-side KDF Hashing      | <--- The encryption happens HERE, on your device.
+-------------------------------+
          |
  [ Encrypted Ciphertext ONLY ]
          | (Travels over HTTPS)
          v
+-------------------------------+
|    Vaultwarden Rust API       |
+-------------------------------+
          |
          v
+-------------------------------+
|        SQLite Database        | <--- If stolen, it's unreadable garbage without your Master PW
+-------------------------------+
```

---

## 🛤️ The First-Time User Workflow
Because this contains your most critical data, the setup is strict.

1. **Phase 1: The TLS Prerequisite (Mandatory)**
   The Bitwarden clients and the Web Crypto SDK **WILL ABSOLUTELY NOT WORK** over plain HTTP. You must place Vaultwarden behind a Reverse Proxy like Caddy or Traefik that provides a valid HTTPS connection. 

2. **Phase 2: The Core Boot**
   Copy `.env.example` to `.env` and configure `ADMIN_TOKEN` securely (e.g. `openssl rand -hex 48`).
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Registration Phase**
   Navigate to your secure domain (`https://vault.yourdomain.com`). Create your account. 

4. **Phase 4: Lockdown the Vault**
   You DO NOT want random people registering on your server.
   Navigate to `https://vault.domain.com/admin` using your `ADMIN_TOKEN`. 
   Flip **"Allow new signups" to FALSE**. Your vault is now ironclad.

---