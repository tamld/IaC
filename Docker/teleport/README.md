<div align="center">

<pre>
 _____    _                  _   
|_   _|__| | ___ _ __   ___ | |_ 
  | |/ _ \ |/ _ \ '_ \ / _ \| __|
  | |  __/ |  __/ |_) | (_) | |_ 
  |_|\___|_|\___| .__/ \___/ \__|
                |_|              
</pre>

# Teleport: The Identity-Native Access Matrix

[![Golang](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](#)

*SSH keys are a liability. Stop sharing them. Identity-based access is here.*

</div>

---

## 🛑 Long-Lived SSH Keys are Ticking Time Bombs.

**Problem:** How do engineers access production databases? If the answer involves distributing a `.pem` file, your infrastructure is compromised waiting to happen. 
**Solution:** **Teleport**. An identity-aware access plane. It replaces static keys with short-lived certificates tied to SSO. When a user logs in, they get access for 8 hours. When the shift ends, the access evaporates.

---

## 🗺️ ASCII Architecture Flow
*A visualization of how Teleport tunnels SSH securely without exposing Port 22.*

```text
[ Engineer ] ---> (tsh login) ---> [ Teleport Gateway Proxy ]
                                            |
                                            | (Verifies Identity Cert)
                                            v
                               +-------------------------+
                               | Teleport Auth Node      | (Certificate Authority)
                               +-------------------------+
                                            |
                         (Reverse Tunnel)   |
+------------------------------------+      |
| Production Server (Target Node)    | <----+
| (No public IPs. Only talks out)    |
+------------------------------------+
```

---

## 🛤️ The First-Time User Workflow
Teleport requires a very rigid bootstrap process because it generates its own Certificate Authorities on first boot.

1. **Phase 1: The Configuration**
   You must set `cluster_name` in the Teleport config. This must map to a valid DNS name (e.g. `teleport.company.com`). Certificates will be minted against this explicitly.

2. **Phase 2: The Core Boot**
   Start the core Auth and Proxy nodes:
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Root User**
   You are completely locked out of the matrix right now. You must drop into the shell of the Auth container to create the master administrator:
   ```bash
   docker exec -it teleport tctl users add admin --roles=editor,access --logins=root,ubuntu
   ```
   Teleport will print an invite URL to your console. Open it in a browser to set a password and mandatory 2FA.

4. **Phase 4: Expand the Matrix**
   Install the Teleport Agent (`teleport.service`) on a remote Linux server. Issue a join token via `tctl tokens add --type=node`. Your remote server will reverse-tunnel into the proxy and appear magically in the web UI.

---