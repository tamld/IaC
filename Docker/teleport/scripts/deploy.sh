#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_TEMPLATE="$REPO_DIR/config/teleport.template.yaml"
CONFIG_OUTPUT="$REPO_DIR/config/_teleport.yaml"
ENV_FILE="$REPO_DIR/.env"
SECRETS_DIR="$REPO_DIR/secrets"

usage() {
  cat <<USAGE
Usage: $0 <up|down>

Commands:
  up    Render config from template and start docker-compose
  down  Stop docker-compose and remove rendered config
USAGE
  exit 1
}

ensure_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ .env not found. Copy .env.example and fill in your values." >&2
    exit 1
  fi
  set -o allexport
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +o allexport
}

render_config() {
  mkdir -p "$(dirname "$CONFIG_OUTPUT")"
  envsubst <"$CONFIG_TEMPLATE" >"$CONFIG_OUTPUT"
  if grep -q '\${' "$CONFIG_OUTPUT"; then
    echo "❌ Unresolved variables remain in $CONFIG_OUTPUT" >&2
    exit 1
  fi
  echo "✅ Generated $CONFIG_OUTPUT"
}

start_stack() {
  (cd "$REPO_DIR" && docker compose up -d)
}

stop_stack() {
  (cd "$REPO_DIR" && docker compose down)
}

case "${1:-}" in
  up)
    ensure_env
    render_config
    start_stack
    ;;
  down)
    stop_stack
    rm -f "$CONFIG_OUTPUT"
    ;;
  *)
    usage
    ;;
esac
