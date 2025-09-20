# 🖥️ Proxmox Infrastructure Module

This module packages production-hardened automation, documentation, and ready-to-share examples for Proxmox Virtual Environment (PVE). All secrets and lab-specific identifiers have been replaced with placeholders so you can adapt them safely.

## 📁 Directory Layout

```
Proxmox/
├── README.md                  # This guide
├── docs/                      # Architecture, workflows, knowledge base
│   ├── architecture/          # System diagrams + component breakdowns
│   ├── knowledge-base/        # Operational how-tos
│   └── workflows/             # Script workflows and sequence diagrams
├── scripts/                   # Reusable automation scripts
│   ├── common.sh              # Shared helpers (logging, telegram, locks)
│   ├── proxmox_backup.sh      # End-to-end backup orchestrator
│   ├── clean_old_vzdump.sh    # Retention for vzdump artifacts
│   ├── clone_pct.sh           # Hardened CT cloning flow
│   ├── destroy_pct.sh         # Safe container destruction + bulk guardrails
│   ├── restore_pct.sh         # Assisted container restore wizard
│   ├── set_timezone.sh        # Apply timezone to CT/VM fleet
│   ├── show_ip_pct.sh         # Enumerate CT IPs with optional subnet filter
│   ├── ssh_hardening.sh       # Opinionated SSH hardening for containers
│   └── deploy_teleport_agent.sh # Parametrised Teleport agent bootstrap
└── terraform/                 # Existing Terraform modules (unchanged)
```

## 🚀 Quick Start

1. Copy `scripts/.env.example` to `.env` and populate environment-specific values (backup paths, Telegram bot token, Teleport endpoints, etc.).
2. Review the desired script in `scripts/` and run in `--dry-run` mode first when available.
3. For safety-critical scripts (destroy/backup), read the corresponding workflow in `docs/workflows/` before production use.

All scripts follow the guardrails defined in `common.sh` (logging, `set -euo pipefail`, optional Telegram notifications, and `flock` locking where relevant).

## 📚 Documentation Highlights

- `docs/architecture/system_architecture.md` — High-level architecture with anonymised remote targets (e.g., `backup-primary.example.lab`).
- `docs/workflows/backup_workflow.md` — Mermaid diagrams for the backup pipeline, retention, and notification flows.
- `docs/workflows/scripts-behavior.md` — Expected behaviors, flags, and edge cases for each script.
- `docs/knowledge-base/pct_backup_restore.md` — Step-by-step restore guidance and retention strategy.

## 🛠️ Script Notes

- **proxmox_backup.sh**
  - Mount checks, capacity guard (`MIN_FREE`), multi-remote sync, Telegram notifications.
  - Integrates `clean_old_vzdump.sh` for shared retention policy.
- **clone_pct.sh**
  - Supports interactive or unattended provisioning with package profiles, logging, and dry-run guard via `PROXMOX_TEST_GUARD`.
- **deploy_teleport_agent.sh** *(new)*
  - No hard-coded IPs; accepts `--auth-server` and environment fallbacks so you can inject your own Teleport topology.
- **show_ip_pct.sh** *(updated)*
  - Filter by subnet through `--subnet` or `SUBNET_PREFIX` env variable instead of a baked-in lab prefix.

## 🔐 Sanitisation Checklist

- No real domains, IP addresses, or tokens are present. Replace placeholders such as `teleport.example.lab:3025` or `backup-primary.example.lab` with your own values.
- `.env` files are ignored by default (`scripts/.gitignore`). Commit only `.env.example` variants for reference.

## 🔄 Next Steps

- Integrate scripts into your CI or cron workflows.
- Map the provided docs to your own infrastructure runbooks.
- Contribute improvements by opening PRs that keep mocks/placeholders for any sensitive values.

Enjoy the automation! Let us know via issues/PRs if additional components should be sanitised for public sharing.
