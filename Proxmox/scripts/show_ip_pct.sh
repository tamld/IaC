#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERR] line $LINENO" >&2' ERR
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -f "$SCRIPT_DIR/common.sh" ] && . "$SCRIPT_DIR/common.sh"
# shellcheck source=common.sh

# Script to show IP addresses of LXC containers.
# Optionally filter by IPv4 subnet prefix via --subnet or SUBNET_PREFIX env.

SUBNET_PREFIX="${SUBNET_PREFIX:-}"

usage() {
  cat <<USAGE
Usage: $0 [--subnet 192.168.100.]

Options:
  --subnet PREFIX   Filter results by IPv4 prefix (e.g., 10.0.0.)
  -h, --help        Show this help message

Environment:
  SUBNET_PREFIX     Default subnet prefix filter when flag omitted.
USAGE
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subnet)
      SUBNET_PREFIX="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      ;;
  esac
done

filter_command() {
  local filter="$1"
  if [[ -n "$filter" ]]; then
    printf "grep '%s'" "${filter//./\\.}"
  else
    printf "cat"
  fi
}

get_info() {
  local vmid=$1
  local hostname iface ip ip_info
  hostname=$(pct exec "$vmid" -- hostname 2>/dev/null || echo n/a)
  ip_info=$(pct exec "$vmid" -- bash -c "ip -4 addr show" 2>/dev/null \
    | awk '/inet / {print $2 " " $NF}' \
    | $(filter_command "$SUBNET_PREFIX"))
  if [[ -z "$ip_info" ]]; then
    printf "%-8s %-20s %-20s %-10s\n" "$vmid" "$hostname" "-" "-"
    return
  fi
  while read -r entry; do
    ip=${entry%% *}
    iface=${entry##* }
    printf "%-8s %-20s %-20s %-10s\n" "$vmid" "$hostname" "$ip" "$iface"
  done <<< "$ip_info"
}

vmids=$(pct list | awk 'NR>1 {print $1}')

echo "Available LXC Containers (Running):"
echo "---------------------------------------------------------------"
printf "%-8s %-20s %-20s %-10s\n" "VMID" "Hostname" "IP Address" "Interface"
echo "---------------------------------------------------------------"
for vmid in $vmids; do
  get_info "$vmid"
done
echo "---------------------------------------------------------------"

if [[ -n "$SUBNET_PREFIX" ]]; then
  echo "Filtered by subnet prefix: $SUBNET_PREFIX"
else
  echo "No subnet filter applied"
fi
