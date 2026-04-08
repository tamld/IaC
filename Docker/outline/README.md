<div align="center">

<pre>
  ___        _   _ _            
 / _ \ _   _| |_| (_)_ __   ___ 
| | | | | | | __| | | '_ \ / _ \
| |_| | |_| | |_| | | | | |  __/
 \___/ \__,_|\__|_|_|_| |_|\___|
                                
</pre>

# Outline: The Beautiful Team Wiki

[![NodeJS](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](#)

*Stop losing company knowledge in Slack threads. Document it beautifully.*

</div>

---

## 🛑 Institutional Knowledge is Evaporating.

**Problem:** How do you deploy the app? Where is the onboarding guide? That information is currently scattered across Slack DMs and forgotten Notion workspaces.
**Solution:** **Outline**. The fastest, most collaborative, and esthetically pleasing open-source knowledge base. It feels like Notion, works flawlessly with Markdown, and lives entirely on your own servers.

---

## 🗺️ ASCII Architecture Flow
*Outline has a notoriously complex stack because it is enterprise-grade.*

```text
[ SSO Identity Provider ]       [ S3 Object Storage ]
(Google / OIDC / Slack)         (AWS S3 / Minio)
           |                              |
           v                              v
+-------------------------------------------------+
|              OUTLINE NODEJS CORE                |
+-------------------------------------------------+
           |                              |
           v                              v
+---------------------+        +------------------+
| PostgreSQL Database |        |   Redis Cache    |
| (Stores text blobs) |        | (Real-time sync) |
+---------------------+        +------------------+
```

---

## 🛤️ The First-Time User Workflow
Outline **WILL NOT START** if you just run `docker compose up`. It requires strict dependencies. Follow this exactly:

1. **Phase 1: The Hard Prerequisites**
   - You MUST have an S3-compatible bucket (like AWS S3 or a local Minio container). Outline uses this for all image uploads.
   - You MUST have an OIDC Identity Provider (like Keycloak, Authentik, or Google Workspace). **Outline has no local username/password system.**

2. **Phase 2: The Secret Forge**
   Copy `.env.example` to `.env`. 
   - Generate two random hex keys using `openssl rand -hex 32`. Place them in `SECRET_KEY` and `UTILS_SECRET`.
   - Fill in your OIDC Client ID and secrets.

3. **Phase 3: The Deployment**
   ```bash
   docker compose up -d
   ```
   *Note: Outline will automatically run Postgres migrations on boot.*

4. **Phase 4: The Genesis**
   Access your Outline domain. You will immediately be redirected to your OIDC provider to login. The first person to log in becomes the ultimate Administrator. You can now start migrating your docs.

---