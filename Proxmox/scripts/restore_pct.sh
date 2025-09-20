#!/usr/bin/env bash
# Test-only guard: active when PROXMOX_TEST_GUARD=1 (no effect in production)
if [[ "${PROXMOX_TEST_GUARD:-0}" == "1" ]]; then
  : "${TEST_SANDBOX:=0}"
  : "${TEST_PREFIX:=test-}"
  if [[ "$TEST_SANDBOX" != "1" ]]; then
    echo "[GUARD] Set TEST_SANDBOX=1 to run this script under test guard" >&2
    exit 98
  fi
  if [[ -n "${NAME:-}" && "${NAME}" != ${TEST_PREFIX}* ]]; then
    echo "[GUARD] NAME must start with prefix '$TEST_PREFIX' when PROXMOX_TEST_GUARD=1" >&2
    exit 99
  fi
  if [[ -n "${VM_NAME:-}" && "${VM_NAME}" != ${TEST_PREFIX}* ]]; then
    echo "[GUARD] VM_NAME must start with prefix '$TEST_PREFIX' when PROXMOX_TEST_GUARD=1" >&2
    exit 99
  fi
fi
set -euo pipefail

# -------------------------------------------------------------
# restore_pct.sh - Restore LXC containers from VZDUMP backups
#
# Usage:
#   ./restore_pct.sh [CTID ...] [options]
#
# Options:
#   -s, --storage <name>   Storage to restore to (default: zfs)
#   -y, --yes              Auto-confirm actions
#   -l, --latest           Use latest backup (default behavior)
#   -h, --help             Show help message
#
# Requirements:
#   - Proxmox VE with pct, pvesm, etc.
#
# Author: DevOps-style UX, safe-by-default, clean output
# -------------------------------------------------------------

BACKUP_DIR="${BACKUP_DIR:-/var/lib/vz/dump}"
AUTO_CONFIRM=0
USE_LATEST=1
STORAGE_DEFAULT="zfs"
STORAGE_LIST=()
CTIDS=()
SELECTED_FILES=()
LIST_ONLY=0
DRY_RUN=0

set -euo pipefail

# Show help
function show_help() {
    echo "Usage: $0 [CTID ...] [options]"
    echo
    echo "Options:"
    echo "  -s, --storage <name>   Storage to restore to (default: zfs)"
    echo "  -y, --yes              Auto-confirm without prompt"
    echo "  -l, --latest           Use latest backup version (default)"
    echo "  -h, --help             Show this help message"
    exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list|-L)
            LIST_ONLY=1; shift ;;
        -s|--storage)
            STORAGE_DEFAULT="$2"; shift 2 ;;
        -y|--yes)
            AUTO_CONFIRM=1; shift ;;
        -l|--latest)
            USE_LATEST=1; shift ;;
        --dry-run)
            DRY_RUN=1; shift ;;
        -h|--help)
            show_help ;;
        -*)
            echo "[ERROR] Unknown option: $1"; exit 1 ;;
        *)
            CTIDS+=("$1"); shift ;;
    esac
done

function line() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'
}

function list_backups() {
    echo "📦 Available VZDUMP backups:"
    line
    printf " %-4s | %-6s | %-19s | %-s\n" "Idx" "CTID" "Date" "Filename"
    line

    BACKUP_MAP=()
    local idx=1
    while IFS= read -r -d '' file; do
        fname=$(basename "$file")
        ctid=$(echo "$fname" | cut -d '-' -f3)
        datetime=$(echo "$fname" | sed -E 's/.*-([0-9]{4})_([0-9]{2})_([0-9]{2})-([0-9]{2})_([0-9]{2})_([0-9]{2}).*/\1-\2-\3 \4:\5:\6/')
        printf " [%2d] | %-6s | %-19s | %s\n" "$idx" "$ctid" "$datetime" "$fname"
        BACKUP_MAP[idx]="$file"
        ((idx++))
    done < <(find "$BACKUP_DIR" -type f -name "vzdump-lxc-*.tar.*" -print0 | sort -z)
    line
}

function select_backups() {
    read -r -p "Enter the index number(s) of backup(s) to restore (e.g. 1 3): " -a TMP_SELECTION
    for sel in "${TMP_SELECTION[@]}"; do
        if [[ -n "${BACKUP_MAP[sel]:-}" ]]; then
            SELECTED_FILES+=("${BACKUP_MAP[sel]}")
        else
            echo "[ERROR] Invalid selection: $sel"
            exit 1
        fi
    done
}

function list_storages() {
    echo "🗃️ Available storage pools:"
    line
    pvesm status | awk 'NR>1 {printf " [%2d] %s (%s)\n", NR-1, $1, $2}'
    mapfile -t STORAGE_LIST < <(pvesm status | awk 'NR>1 {print $1}')
    line
}

function select_storage() {
    DEFAULT_INDEX=1
    for i in "${!STORAGE_LIST[@]}"; do
        [[ "${STORAGE_LIST[$i]}" == "$STORAGE_DEFAULT" ]] && DEFAULT_INDEX=$((i+1)) && break
    done

    read -r -p "Select storage number [default: $DEFAULT_INDEX]: " storage_idx
    if [[ -z "$storage_idx" ]]; then
        STORAGE="${STORAGE_LIST[$((DEFAULT_INDEX - 1))]}"
    else
        STORAGE="${STORAGE_LIST[$((storage_idx - 1))]}"
    fi
    if [[ -z "$STORAGE" ]]; then
        echo "[ERROR] Invalid storage selection."
        exit 1
    fi
    echo "📦 Selected storage: $STORAGE"
}

function restore_ctid() {
    local ctid="$1"
    local file="$2"
    local fname
    fname=$(basename "$file")

    echo "🔄 Restoring CTID $ctid from: $fname"
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "[DRY-RUN] Would destroy old CTID $ctid (if exists) and restore to storage '$STORAGE' from $fname"
        echo "[DRY-RUN] Would start CTID $ctid after restore"
        return
    fi

    if pct status "$ctid" &>/dev/null; then
        local state
        state=$(pct status "$ctid" | awk '{print $2}')
        if [[ "$state" == "running" ]]; then
            echo "⚠️  CTID $ctid is running. Attempting to stop..."
            pct stop "$ctid" || {
                echo "[ERROR] Failed to stop container $ctid. Skipping restore."
                return
            }
        fi
        echo "🗑️  Removing old CTID $ctid before restore..."
        pct destroy "$ctid"
    fi

    pct restore "$ctid" "$file" --storage "$STORAGE" || {
        echo "[ERROR] Failed to restore CTID $ctid."
        return
    }

    echo "▶️ Starting CTID $ctid..."
    pct start "$ctid" && echo "✅ CTID $ctid started."
}

function interactive_mode() {
    list_backups
    select_backups
    echo
    list_storages
    select_storage
    echo
    for file in "${SELECTED_FILES[@]}"; do
        ctid=$(basename "$file" | cut -d '-' -f3)
        restore_ctid "$ctid" "$file"
    done
}

function unattended_mode() {
    if [[ -z "$STORAGE_DEFAULT" ]]; then
        STORAGE="zfs"
    else
        STORAGE="$STORAGE_DEFAULT"
    fi

    echo "📦 Using storage: $STORAGE"
    echo

    for ctid in "${CTIDS[@]}"; do
        file=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "vzdump-lxc-$ctid-*.tar.*" -print | sort -r | head -n1)
        if [[ -z "$file" ]]; then
            echo "[SKIP] No backup found for CTID $ctid"
            continue
        fi

        if [[ $AUTO_CONFIRM -eq 0 ]]; then
            echo "⚠️  Will restore CTID $ctid from $(basename "$file") → storage: $STORAGE"
            read -r -p "Proceed? (y/n): " confirm
            [[ "$confirm" != "y" && "$confirm" != "yes" ]] && continue
        fi

        restore_ctid "$ctid" "$file"
    done
}

# Entry
if [[ $LIST_ONLY -eq 1 ]]; then
    list_backups
    exit 0
fi

# Clear screen only when available; ignore failure in non-TTY/CI
clear >/dev/null 2>&1 || true
echo "🔧 LXC Restore Tool (Proxmox)"
line

if [[ ${#CTIDS[@]} -eq 0 ]]; then
    interactive_mode
else
    unattended_mode
fi

echo
echo "🎉 Restore process completed!"
