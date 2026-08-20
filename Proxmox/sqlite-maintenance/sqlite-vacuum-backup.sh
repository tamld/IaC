#!/usr/bin/env bash
# ============================================================================
# Script: sqlite-vacuum-backup.sh
# Purpose: Non-blocking live backup and automated vacuum for SQLite databases
# ============================================================================
set -euo pipefail

DB_PATH="${1:-/opt/uptime-kuma/data/kuma.db}"
BACKUP_DIR="${2:-/var/backups/sqlite}"
RETENTION_DAYS="${3:-7}"

mkdir -p "${BACKUP_DIR}"
DB_NAME="$(basename "${DB_PATH}")"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TARGET_BACKUP="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sqlite3"

echo "📦 Performing safe online backup for ${DB_PATH}..."
sqlite3 "${DB_PATH}" "VACUUM INTO '${TARGET_BACKUP}';"

echo "🧹 Running PRAGMA optimize..."
sqlite3 "${DB_PATH}" "PRAGMA optimize;"

echo "🗑️ Purging backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "${DB_NAME}_*.sqlite3" -mtime +"${RETENTION_DAYS}" -delete

echo "✅ Backup and optimization completed: ${TARGET_BACKUP}"
