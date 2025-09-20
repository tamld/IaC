#!/usr/bin/env bash
set -euo pipefail

# Common helpers for Proxmox automation scripts

log() { printf '%s - %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

# Log to stdout and append to LOG_FILE if writable
log_message() {
  local message="$*"
  log "$message"
  { [ -n "${LOG_FILE:-}" ] && echo "$message" >> "$LOG_FILE"; } 2>/dev/null || true
}

# Optional Telegram notification (requires BOT_TOKEN/CHAT_ID env vars)
send_telegram() {
  local message="$1"
  [ -z "${BOT_TOKEN:-}" ] && return 0
  [ -z "${CHAT_ID:-}" ] && return 0
  curl -s -X POST -H "Content-Type: application/json" \
       -d "{\"chat_id\": \"$CHAT_ID\", \"message_thread_id\": \"${THREAD_ID:-}\", \"text\": \"$message\"}" \
       "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" >/dev/null || true
}

confirm() {
  local msg="${1:-Proceed? [y/N]: }"
  read -r -p "$msg" ans || true
  [[ "$ans" =~ ^[Yy]$ ]]
}

require_cmd() {
  for c in "$@"; do command -v "$c" >/dev/null 2>&1 || die "Missing required command: $c"; done
}

retry() {
  local attempts="${1:-3}"; shift || true
  local delay="${1:-2}"; shift || true
  local i
  for ((i=1; i<=attempts; i++)); do
    "$@" && return 0
    sleep "$delay"
  done
  return 1
}

with_lock() {
  local lockfile="$1"; shift
  command -v flock >/dev/null 2>&1 || die "flock not available"
  exec 9>"$lockfile"
  flock -n 9 || die "Another instance is running (lock: $lockfile)"
  "$@"
}

trap 'echo "[ERR] line $LINENO" >&2' ERR
