<div align="center">

<pre>
 _____                 __ _ _    
|_   _| __ __ _  ___  / _(_) | __
  | || '__/ _` |/ _ \| |_| | |/ /
  | || | | (_| |  __/|  _| |   < 
  |_||_|  \__,_|\___||_| |_|_|\_\
                                 
</pre>

# Traefik: The Cloud-Native Edge Router

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)

*Expose your containers to the internet securely without touching a single config file.*

</div>

---

## 🛑 Config Files Cannot Keep Up with Cloud-Native.

**Problem:** Containers spin up and down constantly. Old reverse proxies require you to manually write routing rules and reload the daemon every time a new service launches.
**Solution:** **Traefik**. An edge router designed specifically for Docker. It listens to the Docker socket. When you spin up a new container with a Traefik label attached, it instantly routes traffic to it and provisions a Let's Encrypt SSL cert.

---

## 🗺️ ASCII Architecture Flow
*See how Traefik sniffs Docker events to dynamically build routing tables.*

```text
                           +----------------------+
[ Clients on Internet ] -> |  Traefik Edge Router | 
                           |  (Listens on 443)    |
                           +----------------------+
                             |                ^
                (Routes Traffic)              |  (Listens for new Container events)
                             |                |
                             v                |
                        +---------------------------+
                        | /var/run/docker.sock      |
                        +---------------------------+
                             |                |
                       (API labels)      (Web Labels)
                             v                v
                 +---------------+      +---------------+
                 | API Container |      | Web Container |
                 +---------------+      +---------------+
```

---

## 🛤️ The First-Time User Workflow
Traefik is completely configured via Docker Labels. Follow this guide to expose your first app.

1. **Phase 1: The Traefik Boot**
   Start the Traefik router. Traefik *must* have access to `/var/run/docker.sock` to see the other containers in your host.
   ```bash
   docker compose up -d
   ```

2. **Phase 2: The ACME Config**
   Traefik stores TLS certificates in a file called `acme.json`. Ensure this file has exactly `chmod 600` permissions, or Traefik will refuse to start the SSL engine.

3. **Phase 3: Exposing an App**
   To route traffic to an existing container (e.g. your blog), you do NOT edit Traefik. You edit your *blog's* `docker-compose.yml`. Add these labels:
   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.blog.rule=Host(`blog.domain.com`)"
     - "traefik.http.routers.blog.entrypoints=websecure"
     - "traefik.http.routers.blog.tls.certresolver=myresolver"
   ```

4. **Phase 4: The Magic Validation**
   Recreate your blog container (`docker compose up -d`). Traefik immediately detects it, orders the SSL cert, and opens traffic. Go to `https://blog.domain.com`.

---