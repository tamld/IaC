#!/usr/bin/env bash
# ============================================================================
# Script: restoreVM.sh
# Purpose: Gracefully shut down and restore a VirtualBox VM to a snapshot
# ============================================================================
set -euo pipefail

VM_NAME="${1:-W10-Home}"
SNAPSHOT_NAME="${2:-Snapshot 2}"

echo "🔄 Restoring VirtualBox VM: ${VM_NAME} to '${SNAPSHOT_NAME}'..."

# Power off VM gracefully, fallback to force poweroff
VBoxManage controlvm "${VM_NAME}" acpipowerbutton 2>/dev/null || true
sleep 3
VBoxManage controlvm "${VM_NAME}" poweroff 2>/dev/null || true
sleep 2

# Restore snapshot
VBoxManage snapshot "${VM_NAME}" restore "${SNAPSHOT_NAME}"

# Start VM
VBoxManage startvm "${VM_NAME}" --type gui
echo "✅ VM ${VM_NAME} restored and started successfully!"
