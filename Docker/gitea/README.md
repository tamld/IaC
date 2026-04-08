<div align="center">
  <img src="https://gitea.io/images/gitea.svg" width="120" />
  
  # Gitea
  **Painless Self-hosted Git Service**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/gitea/gitea)](https://hub.docker.com/r/gitea/gitea)
</div>

---

## 🦊 What is Gitea?

Gitea is a blazingly fast, lightweight, and open-source GitHub alternative written in Go. It provides code hosting, issue tracking, pull requests, packages, and an integrated CI/CD system via Gitea Actions. Due to its Go architecture, it consumes a fraction of the RAM required by GitLab.

### ✨ Key Features
- **Extremely Low Footprint:** Runs comfortably on a Raspberry Pi or low-end VPS.
- **GitHub Compatibility:** Gitea Actions uses workflows nearly identical to GitHub Actions.
- **Built-in Package Registry:** Host Docker images, NPM packages, Maven, PyPI, and more.
- **Code Review:** Rich Pull Request interface with branching, protections, and inline comments.
- **Robust Database Backing:** Fully configured with PostgreSQL 16.

---

## ⚙️ Architecture & Compose Configuration

This stack deploys Gitea paired with a dedicated PostgreSQL database container. It leverages Docker Healthchecks to ensure startup ordering.

### Port Bindings
- `3000:3000` - The main Web interface and HTTP/HTTPS clone path.
- `2222:22` - The SSH port for Git operations. Mapped to `2222` to avoid conflicting with your host machine's physical SSH daemon.

### Environment Configuration
The system relies on an `.env` file to pass crucial domains. Create `.env` based on the provided `.env.example`:
- `GITEA_ROOT_URL`: E.g., `https://git.example.com` (If missing, defaults to `http://localhost:3000`).
- `GITEA_SSH_DOMAIN`: E.g., `git.example.com`.

### Persistent Volumes
- `gitea_data`: Stores repositories, avatars, and attachments.
- `gitea_db`: Stores the relational database data in PostgreSQL.

---

## 🚀 Getting Started

### 1. Configure the Environment
Ensure your `.env` contains strong database credentials:
```env
POSTGRES_USER=gitea_user
POSTGRES_PASSWORD=secure_password_here
POSTGRES_DB=gitea
GITEA_ROOT_URL=https://git.example.com/
GITEA_SSH_DOMAIN=git.example.com
```

### 2. Boot the Stack
```bash
docker compose up -d
```
Watch the boot sequence using `docker compose logs -f gitea`. It will wait until PostgreSQL is healthy before launching the Go binary.

### 3. Installation Wizard
Navigate to `http://<server-ip>:3000` (or your domain). You will be greeted by the Installation page.
1. The database settings will be pre-filled thanks to the environment variables injected in compose.
2. Ensure your Base URL is correct.
3. At the bottom, set up your **Administrator Account**.
4. Click "Install Gitea".

---

## 💡 Usage & Integration

- **SSH Clones:** Because SSH is mapped to `2222`, clone URLs will look like `ssh://git@git.example.com:2222/user/repo.git`.
- **Gitea Actions:** Go to Site Administration -> Actions and enable the built-in runner, or deploy isolated runners using Gitea act_runner.
- **Woodpecker CI:** For complex DAG pipelines, Gitea integrates flawlessly with [Woodpecker CI](../woodpecker).