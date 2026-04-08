<div align="center">

<pre>
 _____                 _         
|_   _|_      _____ _ __| |_ _   _ 
  | | \ \ /\ / / _ \ '_ \ __| | | |
  | |  \ V  V /  __/ | | | |_| |_| |
  |_|   \_/\_/ \___|_| |_|\__|\__, |
                              |___/ 
</pre>

# Twenty: The Open Source CRM

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](#)

*Salesforce is overkill. Spreadsheets are chaos. A modern, hackable CRM is what you truly need.*

</div>

---

## 🛑 Your Customer Data is Trapped in SaaS Silos.

**Problem:** Managing customer relationships usually involves buying into monolithic platforms like Salesforce, which trap your data and charge exorbitant per-seat licenses.
**Solution:** **Twenty**. An open-source, modern CRM. It gives you deep, customizable control over your workflows, standard GraphQL/REST APIs, and the freedom to self-host. Keep your customer data yours.

---

## 🗺️ ASCII Architecture Flow
*A look inside Twenty's deeply decoupled infrastructure.*

```text
    [ Inbound Webhook / User UI ]
                  |
                  v
       +--------------------+
       |  Nest.js API Core  |
       +--------------------+
         |       |        |
         v       v        v
   +-------+ +-------+ +-------+
   |  PG   | | Redis | | Minio |
   | (DB)  | | (Q)   | | (S3)  |
   +-------+ +-------+ +-------+
```

---

## 🛤️ The First-Time User Workflow
Deploying a full enterprise CRM takes a few steps.

1. **Phase 1: The Blueprint**
   Copy `.env.example` to `.env`. 
   You must carefully fill out `SERVER_URL`, your `ACCESS_TOKEN_SECRET` (generate with `openssl rand -hex 32`), and set up the PostgreSQL credentials.

2. **Phase 2: The Lift Off**
   ```bash
   docker compose up -d
   ```
   Do not access the UI yet! The database is empty.

3. **Phase 3: The Migrations**
   You must instantiate the schema explicitly. 
   ```bash
   docker compose exec -it server yarn database:init
   ```

4. **Phase 4: Sales Mode**
   Everything is up. Navigate to `http://<your-ip>:3000`. Create your first workspace, import a CSV of your contacts, and start dragging cards across your new Kanban pipeline.

---