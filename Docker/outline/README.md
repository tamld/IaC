<div align="center">
  <img src="https://github.com/outline/outline/raw/main/public/images/logo.png" width="120" />
  
  # Outline
  **The Fastest Collaborative Knowledge Base**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/outlinewiki/outline)](https://hub.docker.com/r/outlinewiki/outline)
</div>

---

## 📝 What is Outline?

Outline is a beautiful, lightning-fast, and open-source Notion alternative built specifically for growing teams to document their knowledge. It relies heavily on modern web tech and uses native Markdown to offer an unparalleled, distraction-free writing experience.

### ✨ Key Features
- **Extremely Fast Search:** Find documents instantly across your entire workspace.
- **Real-time Collaboration:** Edit documents simultaneously with your teammates.
- **Slash Commands:** Type `/` to bring up a rich menu of components (diagrams, tables, embeds).
- **Authentication First:** Does not use local basic auth. Integrates directly with Slack, Google, or custom OIDC providers to ensure enterprise security.

---

## ⚙️ Architecture & Compose Configuration

**Important Note:** Outline is a purely front-line application. It **does not ship** with built-in databases. It absolutely requires external connections to a PostgreSQL database (version >= 12) and a Redis instance to function!

### Port Bindings
- `3000:3000` - The main HTTP interface. Should be placed behind a reverse proxy handling HTTPS since OAuth providers require secure callbacks.

### Environmental Requirements
- `SECRET_KEY` & `UTILS_SECRET`: Cryptographic keys used to sign sessions and encrypt sensitive strings in the database.
- `DATABASE_URL`: Connection string to your PostgreSQL instance `postgres://user:pass@host:5432/outline`.
- `REDIS_URL`: Connection string to Redis used for websockets, caching, and background jobs `redis://host:6379`.
- `URL`: The public-facing URL of your installation (e.g. `https://docs.mycompany.com`).

---

## 🚀 Getting Started

### 1. Provision Databases
Before running this stack, ensure you have a PostgreSQL database and a Redis instance available on your network. (You can add them to this `docker-compose.yml` file if you wish to run them strictly locally for Outline).

### 2. Configure Environment
Copy `.env.example` to `.env`:
1. Generate secure 32-byte hex strings for `SECRET_KEY` and `UTILS_SECRET` using `openssl rand -hex 32`.
2. Fill your `DATABASE_URL` and `REDIS_URL`.
3. Set your public `URL`.

### 3. Setup Authentication (Crucial)
Outline has **no local password system**. You must configure at least one OAuth provider. 
If using Slack:
```env
SLACK_CLIENT_ID=your_id
SLACK_CLIENT_SECRET=your_secret
```
Or generic OIDC (like Keycloak/Authentik):
```env
OIDC_CLIENT_ID=...
OIDC_CLIENT_SECRET=...
OIDC_AUTH_URI=...
OIDC_TOKEN_URI=...
```
*(Consult the official Outline documentation for specific OAuth env variables).*

### 4. Boot the Stack
Once your environment file is properly populated, run database migrations and start the server:
```bash
docker compose up -d
```

Navigate to your `URL` to log in via your identity provider and start building your knowledge base!