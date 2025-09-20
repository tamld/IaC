#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERR] line $LINENO" >&2' ERR

# =====================
# Script: clean_old_vzdump.sh
# Description: Cleanup old vzdump backup files, retaining latest 2 per container/VM.
# Usage:
#   ./clean_old_vzdump.sh [-d|--dry-run] [-u|--unattended]
# Example:
#   ./clean_old_vzdump.sh --dry-run
# =====================

# ========== CONFIGURATION ==========
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -f "$SCRIPT_DIR/common.sh" ] && . "$SCRIPT_DIR/common.sh"
ENV_FILE="$SCRIPT_DIR/.env"

# Preserve env-provided value to take precedence over .env
_ENV_VZ_BACKUP_DIR="${VZ_BACKUP_DIR:-}"

# Load environment if exists (.env should not override pre-set env)
# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

# Apply precedence: env > .env > default
if [ -n "${_ENV_VZ_BACKUP_DIR}" ]; then
    VZ_BACKUP_DIR="$_ENV_VZ_BACKUP_DIR"
fi
VZ_BACKUP_DIR="${VZ_BACKUP_DIR:-/var/lib/vz/dump}"

# Retention keep count (default 2) and lock file path
KEEP_N="${VZ_KEEP:-2}"
LOCK_FILE="/var/lock/clean_old_vzdump.lock"

# Flags
DRY_RUN=false
UNATTENDED=false

# ========== ARG PARSER ==========
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -u|--unattended)
            UNATTENDED=true
            shift
            ;;
        -k|--keep)
            KEEP_N="${2:-$KEEP_N}"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ========== LOGGING ==========
# log() and confirm() are provided by common.sh; fallback minimal confirm if missing
confirm() {
    if [ "$UNATTENDED" = true ]; then return 0; fi
    if command -v confirm >/dev/null 2>&1; then
        confirm "Proceed with deleting old backups? [y/N]: "
    else
        read -rp "Proceed with deleting old backups? [y/N]: " answer
        [[ "$answer" =~ ^[Yy]$ ]]
    fi
}

# ========== MAIN ==========
cleanup_old_vzdump_files() {
    if [ ! -d "$VZ_BACKUP_DIR" ]; then
        log "Directory $VZ_BACKUP_DIR not found, skipping cleanup."
        return
    fi

    log "Scanning $VZ_BACKUP_DIR for old vzdump files (keep $KEEP_N)..."
    tmplist="$(mktemp)"; trap 'rm -f "$tmplist"' RETURN
    # Collect lines: "id mtime path"
    while IFS= read -r file; do
        id=$(echo "$file" | sed -E 's/.*vzdump-(lxc|qemu)-([0-9]+)-.*/\2/') || true
        [ -n "$id" ] || continue
        # Cross-platform stat for mtime (macOS vs GNU)
        if mtime=$(stat -f %m "$file" 2>/dev/null); then :; else mtime=$(stat -c %Y "$file" 2>/dev/null || echo 0); fi
        echo "$id $mtime $file" >> "$tmplist"
    done < <(find "$VZ_BACKUP_DIR" -type f \( -name "*.tar.gz" -o -name "*.tar.zst" -o -name "*.log" \))

    # Sort by id asc, mtime desc; then keep first KEEP_N per id
    current_id=""; count=0
    while IFS=' ' read -r id mtime path; do
        if [ "$id" != "$current_id" ]; then
            current_id="$id"; count=0
        fi
        count=$((count+1))
        if [ "$count" -le "$KEEP_N" ]; then
            continue
        fi
        if [ "$DRY_RUN" = true ]; then
            log "[Dry-run] Would delete: $path"
        else
            log "Deleting old file: $path"
            i=0
            while [ $i -lt 3 ]; do
                if rm -f "$path" 2>/dev/null; then
                    break
                fi
                i=$((i+1))
                sleep 1
            done
        fi
    done < <(sort -k1,1 -k2,2nr "$tmplist")

    log "Cleanup completed."
}

if [ "$DRY_RUN" = false ] && [ "$UNATTENDED" = false ]; then
    if ! confirm; then
        log "Aborted by user."
        exit 0
    fi
fi

if command -v flock >/dev/null 2>&1; then
    exec 9>"$LOCK_FILE" || true
    if ! flock -n 9; then
        log "Another cleanup instance is running (lock: $LOCK_FILE). Exiting."
        exit 0
    fi
fi

cleanup_old_vzdump_files
