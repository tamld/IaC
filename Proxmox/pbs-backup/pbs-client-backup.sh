#!/usr/bin/env bash
# ============================================================================
# Script: pbs-client-backup.sh
# Purpose: Chunk-deduplicated, encrypted client-side backup to Proxmox Backup Server
# ============================================================================
set -euo pipefail

PBS_REPOSITORY="${PBS_REPOSITORY:-user@pbs@10.0.0.35:8007:homelab-datastore}"
PBS_PASSWORD="${PBS_PASSWORD:-YourSecurePBSPasswordHere}"
PBS_FINGERPRINT="${PBS_FINGERPRINT:-SHA256:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx}"
ENCRYPTION_KEY_FILE="${ENCRYPTION_KEY_FILE:-/etc/proxmox-backup/encryption-key.json}"

BACKUP_TARGET_NAME="${1:-host-root}"
BACKUP_PATH="${2:-/etc /var/lib/containers /opt}"

export PBS_REPOSITORY
export PBS_PASSWORD
export PBS_FINGERPRINT

echo "🚀 Initiating encrypted chunk backup for ${BACKUP_TARGET_NAME} to PBS..."

proxmox-backup-client backup \
  "${BACKUP_TARGET_NAME}.pxar:${BACKUP_PATH}" \
  --keyfile "${ENCRYPTION_KEY_FILE}" \
  --crypt-mode encrypt

echo "🧹 Running retention prune policy on PBS..."
proxmox-backup-client prune host/"${BACKUP_TARGET_NAME}" \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12

echo "✅ Backup and prune cycle completed successfully!"
