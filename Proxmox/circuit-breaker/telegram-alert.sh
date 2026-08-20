#!/usr/bin/env bash
# ============================================================================
# Script: telegram-alert.sh
# Purpose: Dispatch Circuit Breaker trip notifications to Telegram with 1-line rescue commands
# ============================================================================
SERVICE_NAME="${1:-unknown-service}"
HOSTNAME="$(hostname)"
CT_IP="$(hostname -I | awk '{print $1}')"

BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-YOUR_BOT_TOKEN_HERE}"
CHAT_ID="${TELEGRAM_CHAT_ID:-YOUR_CHAT_ID_HERE}"
THREAD_ID="${TELEGRAM_THREAD_ID:-4}"

TEXT="🔴 <b>[CB] Circuit Breaker Tripped</b>

<b>Service:</b> <code>${SERVICE_NAME}</code>
<b>Host:</b> ${HOSTNAME} (${CT_IP})
<b>Symptom:</b> 5 crashes in 10min → Auto-restart <b>DISABLED</b> to protect CPU/IO.

<b>Troubleshooting:</b>
<code>journalctl -u ${SERVICE_NAME} -n 30 --no-pager</code>

<b>Recovery after fix:</b>
<code>systemctl reset-failed ${SERVICE_NAME} && systemctl start ${SERVICE_NAME}</code>"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d message_thread_id="${THREAD_ID}" \
  -d parse_mode="HTML" \
  -d text="${TEXT}" > /dev/null 2>&1 || true
