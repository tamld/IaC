#!/usr/bin/env bash
# Test-only guard: active when PROXMOX_TEST_GUARD=1 (no effect in production)
if [[ "${PROXMOX_TEST_GUARD:-0}" == "1" ]]; then
  : "${TEST_SANDBOX:=0}"
  : "${TEST_PREFIX:=test-}"
  if [[ "$TEST_SANDBOX" != "1" ]]; then
    echo "[GUARD] Set TEST_SANDBOX=1 to run this script under test guard" >&2
    exit 98
  fi
  # Optionally enforce naming when environment provides a VM/CT name
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
[ -f "$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/common.sh" ] && . "$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/common.sh"
# shellcheck source=common.sh

# Initialize
PCTS_TO_DESTROY=()
CONFIRM=""
AUTO_CONFIRM=0
DRY_RUN=0
BULK_LIMIT=${BULK_LIMIT:-10}
FORCE_BULK=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_CONFIRM=1
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=1
            shift
            ;;
        --force-bulk)
            FORCE_BULK=1
            shift
            ;;
        -*)
            echo "[ERROR] Unknown option: $1"
            exit 1
            ;;
        *)
            PCTS_TO_DESTROY+=("$1")
            shift
            ;;
    esac
done

# Attend mode if no arguments
if [ ${#PCTS_TO_DESTROY[@]} -eq 0 ]; then
    echo "Available containers:"
    pct list
    read -r -a PCTS_TO_DESTROY -p "Enter the CTIDs of the containers you want to destroy (separate by space, e.g., 101 102): "
    if [ ${#PCTS_TO_DESTROY[@]} -eq 0 ]; then
        echo "Error: No CTIDs provided."
        exit 1
    fi
fi

# Confirmation if not auto-confirm and not dry-run
if [ $AUTO_CONFIRM -eq 0 ] && [ $DRY_RUN -eq 0 ]; then
    echo "You have selected the following containers to destroy: ${PCTS_TO_DESTROY[*]}"
    read -r -p "Are you sure you want to destroy these containers? This action cannot be undone! (yes/YES/y to confirm): " CONFIRM
    CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')
    if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
        echo "Aborting container destruction."
        exit 1
    fi
fi

# Guard against unattended bulk actions (non-dry-run)
if [ $AUTO_CONFIRM -eq 1 ] && [ $DRY_RUN -eq 0 ] && [ ${#PCTS_TO_DESTROY[@]} -gt "$BULK_LIMIT" ] && [ $FORCE_BULK -eq 0 ]; then
    echo "Refusing unattended bulk destroy of ${#PCTS_TO_DESTROY[@]} containers (> $BULK_LIMIT). Use --force-bulk to override."
    exit 1
fi

# Loop and destroy containers
for CTID in "${PCTS_TO_DESTROY[@]}"; do
    if ! pct status "$CTID" > /dev/null 2>&1; then
        echo "[SKIP] Container with CTID $CTID does not exist."
        continue
    fi

    if [ $DRY_RUN -eq 1 ]; then
        if pct status "$CTID" | grep -q "status: running"; then
            echo "[DRY-RUN] Would stop and destroy running container $CTID."
        else
            echo "[DRY-RUN] Would destroy stopped container $CTID."
        fi
        continue
    fi

    if pct status "$CTID" | grep -q "status: running"; then
        echo "Stopping container $CTID..."
        pct stop "$CTID" || { echo "Error: Failed to stop $CTID. Skipping."; continue; }
    fi
    echo "Destroying container $CTID..."
    pct destroy "$CTID" && echo "Container $CTID destroyed successfully." || echo "Error: Failed to destroy $CTID."
done

echo "Container destruction process completed."
