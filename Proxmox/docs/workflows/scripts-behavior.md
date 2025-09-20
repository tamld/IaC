# Proxmox Scripts Workflows & Behaviors

This document describes the intended behaviors and user workflows for core scripts, to guide testing and future changes.

## clean_old_vzdump.sh
- Purpose: Retain the latest two vzdump artifacts per CT/VM; delete older ones.
- Inputs:
  - `VZ_BACKUP_DIR` (env) > `.env` > default `/var/lib/vz/dump`
  - Flags: `--dry-run`, `--unattended` (skip confirm), `--keep N` (default 2)
- Behavior:
  - Scan `*.tar.gz`, `*.tar.zst`, `*.log` grouped by ID; keep N newest per ID.
  - Dry-run prints `[Dry-run] Would delete: <file>` and does not delete.
  - Attended mode asks for confirmation once.
  - Lockfile: prevents concurrent runs (flock at `/var/lock/clean_old_vzdump.lock`).

## destroy_pct.sh
- Purpose: Stop and destroy one or more LXC containers.
- Inputs: CTIDs as args, or prompt in attended mode.
- Flags: `--dry-run`, `--yes`
- Behavior:
  - For non-existent CTID: print `[SKIP] ... does not exist`.
  - For running CT: dry-run prints `Would stop and destroy running container <id>`.
  - Requires confirmation unless `--yes` or `--dry-run`.
  - Bulk guard: in unattended mode (with `--yes`), abort if count exceeds `BULK_LIMIT` (default 10) unless `--force-bulk` is provided.

## destroy-VM.sh
- Purpose: Stop and destroy QEMU VMs with ID below threshold.
- Flags: `--max-id N` (default 200), `--dry-run`, `--yes`, `--bulk-limit N`, `--force-bulk`
- Behavior:
  - Select VMIDs strictly less than threshold.
  - Dry-run prints `[DRY-RUN] Would stop and destroy VM <id>`.
  - Requires confirmation unless `--yes` or `--dry-run`.
  - Bulk guard: in unattended mode, abort if selected VMs exceed `BULK_LIMIT` (default 10) unless `--force-bulk` is passed. Use thresholds to scope impact.

## restore_pct.sh
- Purpose: Restore CT from vzdump.
- Inputs: Interactive selection of backup(s) and storage, or unattended via flags.
- Behavior:
  - List available backups with indices; select and restore, handling running containers by stopping first.
  - Future: consider env override for backup dir to improve testability.

## proxmox_backup.sh
- Purpose: End-to-end backup (configs + vzdump) and cloud sync.
- Behavior:
  - Load env from local `.env` near script, else fallback `/root/scripts/.env`.
  - Prefer safety: fail fast, and verify mounts before proceeding.
  - Assemble `BACKUP_REMOTES` from configured drives and call `multi_drive_backup.sh` to push configs and vzdump artifacts under `$DATE` and `$DATE/vzdump`.
  - Retention: calls `clean_old_vzdump.sh --keep ${VZ_KEEP:-2}` with lock to centralize cleanup.
- If `MIN_FREE` is set in `.env` (e.g., `50G`), pass it to `multi_drive_backup.sh` to filter destinations by available capacity.
  - Default `MIN_FREE` is `50G` (can be overridden in `.env`).
  - Future: refactor retention to reuse `clean_old_vzdump.sh`.

## rclone_health.sh
- Purpose: Check availability (listable) of rclone remotes/paths and optionally capacity.
- Usage: `rclone_health.sh --remotes "remoteA:/path,remoteB:/path" [--json] [--min-free SIZE] [--require-min-free]`
- Behavior:
  - ONLINE/OFFLINE detection via `rclone lsjson` with timeout; outputs text or JSON.
  - With `--min-free`, mark low_space remotes using `rclone about --json` free bytes.
  - Exit 0 if at least one remote online (and at least one meets min-free if `--require-min-free`); otherwise exit 1.

## multi_drive_backup.sh
- Purpose: Copy/sync a source path to all online remotes intelligently.
- Inputs:
  - `--remotes "rA:/base,rB:/base,..."` or env `BACKUP_REMOTES` (comma-separated)
  - `--min-online N` (default 1), `--mode proceed|abort` (default proceed)
  - `--op copy|sync` (default copy), `--dry-run`
  - `--min-free SIZE` (optional): only choose remotes with free >= SIZE (e.g., 50G)
- Behavior:
  - If number of online remotes is 0: abort with notify.
  - If online < min-online: abort (mode=abort) or proceed partial (mode=proceed) and notify.
  - Copy/sync to all online remotes under `<remote_base>/<dest-subpath>`.
  - Retries rclone operations (3x) for robustness.
