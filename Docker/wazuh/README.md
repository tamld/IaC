<div align="center">

<pre>
__        __               _     
\ \      / /_ _ _____   _| |__  
 \ \ /\ / / _` |_  / | | | '_ \ 
  \ V  V / (_| |/ /| |_| | | | |
   \_/\_/ \__,_/___|\__,_|_| |_|
                                
</pre>

# Wazuh: The Open Source SIEM & XDR

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)

*You cannot fight threats you cannot see. Unify your endpoint defense.*

</div>

---

## 🛑 Intruders Move Laterally in Silence.

**Problem:** Modern attacks don't happen in a giant blast; they happen quietly. Setting up disparate systems — syslog servers, anti-virus agents — leads to alert fatigue and siloed data.
**Solution:** **Wazuh**. A complete Open Source Security platform (SIEM + XDR). Wazuh centrally detects malware, audits file modifications, analyzes logs, and triggers automated active responses to block attackers.

---

## 🗺️ ASCII Architecture Flow
*See how a single failed SSH login triggers a global network firewall response.*

```text
[ Ubuntu Target Node ]
         | (Attacker Brute Forces Port 22)
         v
+------------------------+      Alert        +-----------------------+
|  Wazuh Agent           | ----------------> |  Wazuh Manager Core   |
|  (Reads /var/log/auth) |                   |  (Runs Rules Engine)  |
+------------------------+                   +-----------------------+
         ^                                           |
         | (Command: Block IP via iptables)          | (Stores event)
         |                                           v
+------------------------+                   +-----------------------+
|  Active Response Daemon| <---------------- |   Wazuh Indexer       |
+------------------------+                   |   (Dashboard/UI)      |
                                             +-----------------------+
```

---

## 🛤️ The First-Time User Workflow
Wazuh requires enterprise-tier resources. Do not attempt to run this on a Raspberry Pi.

1. **Phase 1: Memory Prerequisite**
   Wazuh's indexer requires high virtual memory limits. Run this on your host machine:
   ```bash
   sysctl -w vm.max_map_count=262144
   ```
   (Persist it in `/etc/sysctl.conf`). You will also need at least **8GB RAM** dedicated to this stack.

2. **Phase 2: Certificate Generation**
   Wazuh components enforce mTLS internally. You must run the cert generator before boot:
   ```bash
   docker compose -f generate-indexer-certs.yml run --rm generator
   ```

3. **Phase 3: The Deployment**
   ```bash
   docker compose up -d
   ```
   Wait 2-4 minutes. The indexer is heavy and takes time to initialize.

4. **Phase 4: Agent Enrollment**
   Login to `https://<server-ip>:443`. Add your first agent. The platform will give you a `curl` command. SSH into a target node, paste the command. Your node will appear on the dashboard instantly, transmitting its security posture.

---