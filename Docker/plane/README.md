<div align="center">

<pre>
 ____  _                  
|  _ \| | __ _ _ __   ___ 
| |_) | |/ _` | '_ \ / _ \
|  __/| | (_| | | | |  __/
|_|   |_|\__,_|_| |_|\___|
                          
</pre>

# Plane: The Open-Source Jira Alternative

[![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)](#)

*Stop paying massive per-seat Jira taxes just to track a bug.*

</div>

---

## 🛑 Project Management Should Not Be Bloatware.

**Problem:** Tracking software development requires structure. But enterprise tools like Jira are slow, bloated, and charge exorbitant per-seat licenses.
**Solution:** **Plane.so**. An ultra-sleek, open-source project management tool specifically engineered for software teams. Cycles, Modules, and Views in a hyper-fast Next.js interface.

---

## 🗺️ ASCII Architecture Flow
*Plane operates on a modern, decoupled microservices stack.*

```text
       [ Developer Browser ]
                 |
                 v
+----------------------------------+
|    Plane Frontend (Next.js)      |
+----------------------------------+
                 | (REST / GraphQL)
                 v
+----------------------------------+
|     Plane API (Django Core)      |
+----------------------------------+
        |                 |
        v                 v
+-------------+    +-------------+
| PostgreSQL  |    |    Redis    |
| (Tx Data)   |    | (Celery/MQ) |
+-------------+    +-------------+
```

---

## 🛤️ The First-Time User Workflow
Plane requires multiple microservices to run in harmony.

1. **Phase 1: The Blueprint**
   Copy the default `.env`. You must define the base web URL so CORS and authentication callbacks route correctly.
   Generate random strings for `SECRET_KEY`.

2. **Phase 2: Container Liftoff**
   Start the application suite. This brings up the Web, API, Database, and Background Workers.
   ```bash
   docker compose up -d
   ```

3. **Phase 3: The Setup Wizard**
   Open your browser to `http://<your-ip>`. 
   - You will be greeted by the Plane Setup Dashboard.
   - Enter your email and workspace name.
   - Plane will handle the initial database seeding.

4. **Phase 4: Issue Zero**
   Welcome to your new HQ. Create your first Project, establish a "Cycle" (Sprint), and create your first Issue. Connect the GitHub integration to automatically close issues when PRs are merged.

---