<div align="center">
  <img src="https://goteleport.com/static/d0c242944ca0dcaf65eb7af191b7e452/3bbf2/teleport-logo.png" width="200" />
  
  # Teleport
  **The Identity-Native Infrastructure Access Platform**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/gravitational/teleport)](https://hub.docker.com/r/gravitational/teleport)
</div>

---

## 🔑 What is Teleport?

Teleport allows engineers and security professionals to unify access for SSH servers, Kubernetes clusters, web applications, and databases across all environments. It completely eliminates the need for VPNs, jump hosts, and static SSH keys.

Instead of managing `authorized_keys` files, Teleport uses temporary, short-lived X.509 and SSH certificates tied directly to an identity provider (like Google Workspace, GitHub, or Okta).

### ✨ Key Features
- **Zero Trust Architecture:** Never expose SSH ports (port 22) to the internet again.
- **Session Recording:** Every single keystroke executed in an SSH session or Kubernetes pod is recorded and playable like a YouTube video.
- **Audit Logging:** Comprehensive JSON audit log connecting every action back to an authenticated identity.
- **Consolidated Access:** A single web portal to access internal Web Apps, SSH nodes, and PostgreSQL databases securely.

---

## ⚙️ Architecture & Compose Configuration

This stack deploys the main Teleport Authentication and Proxy server.

### Port Bindings
- `3080:3080` - The main Web UI and HTTPS Proxy port (Clients connect here).
- `3023:3023` - SSH Proxy port.
- `3024:3024` - SSH Tunnels port (used by reverse tunnels).
- `3025:3025` - Auth Service port (internal cluster communications).

### Persistent Volumes
- `./config` -> Stores the `teleport.yaml` configuration file.
- `./data` -> Stores the cluster state, backend database, and session recordings.

---

## 🚀 Getting Started

### 1. Generating Initial Configuration
Teleport refuses to start without a valid `teleport.yaml` file. Generate one dynamically into the `./config` directory:
```bash
docker run --hostname localhost --rm \
  --entrypoint=/bin/sh \
  -v $(pwd)/config:/etc/teleport \
  public.ecr.aws/gravitational/teleport:15 \
  -c "teleport configure > /etc/teleport/teleport.yaml"
```

### 2. Boot the Server
```bash
docker compose up -d
```

### 3. Create the First Admin User
Because Teleport is highly secure, it doesn't have a default admin login. You must use the embedded `tctl` administrative tool to spawn a one-time signup link:
```bash
docker compose exec teleport tctl users add teleport-admin --roles=editor,access --logins=root,ubuntu,admin
```
*(Replace `root,ubuntu,admin` with the actual OS-level user names you want this Teleport user to have permission to assume when SSHing).*

Copy the link it outputs (it looks like `https://<server>:3080/web/invite/...`), paste it into your browser, set a password, and scan the QR code to set up Two-Factor Authentication.

---

## 💡 Usage

To SSH into a machine added to the cluster, you can either:
1. Click the "Connect" button directly inside the Web UI for an instant browser-based terminal.
2. Or use the official `tsh` command line tool on your local laptop:
```bash
tsh login --proxy=teleport.example.com --user=teleport-admin
tsh ssh root@node-name
```