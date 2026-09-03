# 🔑 Dual-Tier Identity & Access Management (ADR-028 Blueprint)

> **Modern Zero-Trust Access combining Passkey FIDO2 (Pocket ID) with Centralized ForwardAuth SSO (Authelia + LLDAP).**

---

## 📌 Architectural Concept

Traditional homelabs face a dilemma:
* Modern apps support **OIDC / Passkeys**, but legacy or simple web dashboards do not.
* Basic reverse proxies use **HTTP Basic Auth**, which is vulnerable to brute-force attacks and lacks multi-factor authentication (MFA).

### The Dual-Tier Solution:
1. **Tier 1 (Passkey-Native Admin & Infrastructure)**:
   * **Pocket ID**: Lightweight, passwordless Identity Provider utilizing WebAuthn / FIDO2 (TouchID, YubiKey, FaceID).
   * Native OIDC provider for modern tools (Gitea, Proxmox Backup Server, OpenCode).
2. **Tier 2 (Unified ForwardAuth for Web Apps)**:
   * **Authelia**: Intercepts requests at Traefik edge via ForwardAuth middleware.
   * Backed by lightweight LDAP (LLDAP).

---

## 🚀 Deployment

1. **Copy and edit environment configuration**:
   ```bash
   cp .env.example .env
   # Set DOMAIN_NAME and passwords
   ```

2. **Start the stack**:
   ```bash
   docker compose up -d
   ```

3. **Access Interfaces**:
   * Pocket ID: `https://id.example.com`
   * Authelia: `https://auth.example.com`
