<div align="center">
  <img src="https://raw.githubusercontent.com/woodpecker-ci/woodpecker/master/docs/logo.svg" width="120" />
  
  # Woodpecker CI
  **Simple yet powerful CI/CD engine with a pluggable architecture.**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/woodpeckerci/woodpecker-server)](https://hub.docker.com/r/woodpeckerci/woodpecker-server)
</div>

---

## 🦅 What is Woodpecker CI?

Woodpecker is a community-driven CI/CD engine born as a fork of Drone CI. It integrates natively with Git providers (like GitHub, GitLab, and Gitea). When connected, Woodpecker automatically listens to webhooks and executes your pipelines inside clean, ephemeral Docker containers.

### ✨ Key Features
- **Container Native:** Every step of your pipeline runs inside a Docker container. No more dependency hell or polluted build nodes.
- **Deep Gitea Integration:** Logs in natively via Gitea OAuth2. Commits, tags, and PRs in Gitea instantly trigger builds.
- **Zero Master-Node Bottlenecks:** Uses a Server-Agent architecture. You can spawn endless agents on Raspberry Pis, cloud VPSes, or home servers.
- **Plugins Ecosystem:** Need to publish a Docker image? Notify Telegram? There’s a plugin for it, and writing one is as simple as creating a bash script in a container.

---

## ⚙️ Architecture & Compose Configuration

This stack consists of two services: `woodpecker-server` (the brain/UI) and `woodpecker-agent` (the worker).

### Port Bindings
- `8000:8000` - The Web UI for Woodpecker Server.
- `9000` (Internal) - The gRPC port used by agents to check for jobs.

### Security / Daemon Access
- `woodpecker-agent` binds to `/var/run/docker.sock` on your host. This allows the agent to spin up sibling containers to execute pipeline code. Ensure your host environment is secured.

---

## 🚀 Getting Started (Integration with Gitea)

Woodpecker requires an OAuth application created in your Git provider to authorize users and intercept webhooks.

### 1. Create a Gitea OAuth2 Application
1. In your Gitea instance, click your Profile -> Settings -> Applications.
2. Under "Manage OAuth2 Applications", create a new app:
   - **App Name:** `Woodpecker CI`
   - **Redirect URI:** `http://<your-woodpecker-ip>:8000/authorize`
3. Save it. Copy the **Client ID** and **Client Secret**.

### 2. Configure Woodpecker
Copy `.env.example` to `.env` and fill the variables:
```env
GITEA_URL=http://<your-gitea-ip>:3000
GITEA_OAUTH_CLIENT=your_client_id_here
GITEA_OAUTH_SECRET=your_client_secret_here
WOODPECKER_HOST=http://<your-woodpecker-ip>:8000
WOODPECKER_AGENT_SECRET=generate_a_random_string_here
```
*(The Agent Secret is used internally to authenticate Agents to the Server).*

### 3. Start the Stack
```bash
docker compose up -d
```

### 4. Create your first Pipeline
1. Log into Woodpecker at `http://<server-ip>:8000`.
2. Sync your repositories and enable the one you want to build.
3. In your Git repository, commit a file named `.woodpecker.yml`:
```yaml
pipeline:
  build:
    image: node:18
    commands:
      - npm install
      - npm test
```
4. Push to Gitea. Woodpecker will catch the event and run your pipeline!