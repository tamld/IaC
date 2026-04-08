<div align="center">
  <img src="https://plane.so/images/plane-logo.svg" width="150" />
  
  # Plane
  **The Open-source Jira Alternative**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/makeplane/plane-frontend)](https://hub.docker.com/r/makeplane/plane-frontend)
</div>

---

## ✈️ What is Plane?

Plane is a surprisingly fast, simple, and extensible open-source project and issue tracking tool. It is built to mirror the power of enterprise tools like Jira or Linear but keeps the user interface incredibly clean and focused on speed.

### ✨ Key Features
- **Issues & Cycles:** Use issues for daily tasks and group them into 'Cycles' (Sprints) or 'Modules' (Epics).
- **Multiple Views:** Track work via Kanban boards, Calendars, Lists, or Spreadsheets.
- **Developer First:** Features a heavy keyboard-oriented design (Press `Ctrl+K` to open the command palette) and full Markdown support on issue descriptions.
- **Analytics & Burn-downs:** Generate insights on team velocity and issue burn-down automatically.
- **Rich Integrations:** Bi-directional sync with GitHub, Slack notifications, and robust Webhooks.

---

## ⚙️ Architecture & Compose Configuration

The stack explicitly defines the application layer. Standard deployments of Plane require an external PostgreSQL, Redis, and MinIO/S3 bucket configured via environment variables.

### Port Bindings
- `8080:3000` - The main Plane Frontend interface is exposed on port `8080`.
- The `plane-api` backend runs implicitly and is talked to over the internal docker network.

### Structure
- `plane-web`: The Next.js frontend handling UI elements.
- `plane-api`: The Django backend processing logic.

---

## 🚀 Getting Started

### 1. Database Pre-requisites
Ensure PostgreSQL (14+) and Redis are reachable. Plane relies heavily on relational structuring and Redis-driven task queues (Celery). 

### 2. Configure Environment
Copy `.env.example` to `.env`. Specify the API URLs so the frontend knows where to fetch data:
```env
NEXT_PUBLIC_API_BASE_URL=http://<your-server-ip>:8080/api
DATABASE_URL=postgres://plane_user:pass@postgresql_host:5432/plane
REDIS_URL=redis://redis_host:6379/0
```

### 3. Run Database Migrations
Before booting the application fully, you must migrate the database:
```bash
docker compose run --rm plane-api python manage.py migrate
```

### 4. Boot the Stack
Once migrations complete, start the application:
```bash
docker compose up -d
```

### 5. Setup your Workspace
Navigate to `http://<your-server-ip>:8080`. You'll be prompted to create your primary workspace. Once created, you can invite team members and define your issue states.