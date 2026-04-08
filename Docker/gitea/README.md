<div align="center">

<pre>
  ____ _ _             
 / ___(_) |_ ___  __ _ 
| |  _| | __/ _ \/ _` |
| |_| | | ||  __/ (_| |
 \____|_|\__\___|\__,_|
                       
</pre>

# Gitea: The Extremely Fast, Lightweight Git Server

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](#)

*Don't let your proprietary source code live on third-party servers. Host it yourself.*

</div>

---

## 🛑 Absolute Control Over Your Codebase.

**Problem:** Pushing sensitive enterprise code to an external party is a security liability. And running a massive alternative like GitLab requires huge RAM overhead.
**Solution:** **Gitea**. A painless self-hosted Git service written in Go. It provides 90% of GitHub's features (issues, PRs, actions) using a fraction of the hardware.

---

## 🗺️ ASCII Architecture Flow
*See exactly how your code propagates through the internal ecosystem without a heavy visual renderer.*

```text
  [ Developer Laptop ]
         |
         | (git push)
         v
+-----------------------+     (Webhooks)     +-------------------+
|  Reverse Proxy        | -----------------> |  CI/CD Runners    |
|  (Traefik/Nginx)      |                    +-------------------+
+-----------------------+                              |
         |                                             |
         v                                             v
+-----------------------+                      +---------------+
|     Gitea Core        | <==================> | Gitea DB (PG) |
+-----------------------+                      +---------------+
```

---

## 🛤️ The First-Time User Workflow
Self-hosting a code forge is a massive responsibility. Here is how your first 15 minutes look.

1. **Phase 1: The Database Link**
   Gitea requires state storage. Ensure `docker-compose.yml` mounts a dedicated PostgreSQL and Redis instance for it. 
   Create `.env` and set your `POSTGRES_PASSWORD`.

2. **Phase 2: Lift Off**
   Run the stack. It will take ~30 seconds for the database to seed.
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Initialization Lock**
   Navigate to `http://<your-ip>:3000`. You will be intercepted by the **Gitea Setup Wizard**.
   - Input your database credentials exactly as defined in `.env`.
   - Setup the root Administrator account. **Whoever registers first becomes the master admin.**

4. **Phase 4: Day-2 Operations**
   Add your public SSH Keys to your profile. Create a test organization. Point your local Git remotes to your server IP. The codebase is now yours.

---