#!/usr/bin/env bash
# ============================================================================
# Script: create_podman_lxc.sh
# Purpose: Provision a hardened, daemonless Podman-ready LXC on Proxmox VE
# ============================================================================
set -euo pipefail

VMID="${1:-110}"
HOSTNAME="${2:-svc-app-prod}"
IP_CIDR="${3:-10.0.0.110/24}"
GATEWAY="${4:-10.0.0.1}"
DISK_SIZE="${5:-8G}"
RAM_MB="${6:-1024}"
CORES="${7:-1}"
STORAGE="${8:-local-lvm}"
TEMPLATE="${9:-local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst}"

echo "🚀 Creating LXC CT${VMID} (${HOSTNAME})..."

pct create "${VMID}" "${TEMPLATE}" \
  --hostname "${HOSTNAME}" \
  --net0 "name=eth0,bridge=vmbr0,ip=${IP_CIDR},gw=${GATEWAY},type=veth" \
  --memory "${RAM_MB}" \
  --cores "${CORES}" \
  --rootfs "${STORAGE}:${DISK_SIZE}" \
  --ostype ubuntu \
  --unprivileged 1 \
  --features "nesting=1,keyctl=1" \
  --start 1

echo "⏳ Waiting for container startup..."
sleep 5

echo "📦 Installing Podman & Systemd tools..."
pct exec "${VMID}" -- apt-get update -y
pct exec "${VMID}" -- apt-get install -y podman systemd curl ca-certificates

echo "✅ CT${VMID} is ready with daemonless Podman!"
