#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERR] line $LINENO" >&2' ERR
[ -f "$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/common.sh" ] && . "$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/common.sh"
# shellcheck source=common.sh

# Script to set timezone for all running LXC containers

TIMEZONE="Asia/Ho_Chi_Minh"

# Get list of running LXC containers
vmids=$(pct list | awk 'NR>1 {print $1}')

echo "Setting timezone to $TIMEZONE for all running LXC containers..."

for vmid in $vmids; do
  echo "--------------------------------------------------"
  echo "Processing container VMID: $vmid"
  pct exec "$vmid" -- ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  pct exec "$vmid" -- bash -c "echo $TIMEZONE > /etc/timezone"
  echo "[$vmid] Timezone set to $TIMEZONE"
done

echo "--------------------------------------------------"
echo "Done."
