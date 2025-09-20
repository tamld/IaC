#!/usr/bin/env bash
# Test-only guard: active when PROXMOX_TEST_GUARD=1 (no effect in production)
if [[ "${PROXMOX_TEST_GUARD:-0}" == "1" ]]; then
  : "${TEST_SANDBOX:=0}"
  : "${TEST_PREFIX:=test-}"
  if [[ "$TEST_SANDBOX" != "1" ]]; then
    echo "[GUARD] Set TEST_SANDBOX=1 to run this script under test guard" >&2
    exit 98
  fi
  # If a name variable is provided by the environment or earlier parsing, enforce prefix
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

###############################################################################
# clone_pct.sh - Clone one or more LXC containers from a template (default: 8003)
# ------------------------------------------------------------------------------
# This script clones LXC containers from a base template and optionally installs
# full or minimal packages, applies SSH hardening, and copies host SSH keys.
#
# USAGE:
#   ./clone_pct.sh -n web1 api1 db1 [--full|--mini] [-t 9001] [-d|--dry-run]
#
# OPTIONS:
#   -n, --name         One or more container names to create (required)
#   -f, --full         Install full package set
#   -m, --mini         Install minimal package set (default)
#   -t, --template     Template CTID to clone from (default: 8003)
#   -d, --dry-run      Simulate actions without executing
#   -h, --help         Show this help message
#
# NOTES:
#   - Providing only -n triggers unattended mode automatically.
#   - Running without arguments starts interactive (attended) mode.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
LOG_DIR="/var/log"
LOG_FILE="$LOG_DIR/clone_pct.log"
SUMMARY_FILE="$LOG_DIR/summary.csv"
mkdir -p "$LOG_DIR"

# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

INSTALL_MODE="minimal"
TEMPLATE_ID="8003"
NAME_LIST=()
UNATTENDED=false
DRY_RUN=false

exec > >(tee -a "$LOG_FILE") 2>&1

show_help() {
    grep '^#' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

[[ "$#" -gt 0 && "$1" == "-n" ]] && UNATTENDED=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                NAME_LIST+=("$1")
                shift
            done
            ;;
        -f|--full) INSTALL_MODE="full"; shift ;;
        -m|--mini) INSTALL_MODE="minimal"; shift ;;
        -t|--template) TEMPLATE_ID="$2"; shift 2 ;;
        -d|--dry-run) DRY_RUN=true; shift ;;
        -h|--help) show_help ;;
        *) echo "[ERROR] Unknown argument: $1"; show_help ;;
    esac
done

if [[ ${#NAME_LIST[@]} -eq 0 ]]; then
    echo "[INFO] No name provided. Entering attended mode..."
    read -rp "Enter container name(s) separated by space: " -a NAME_LIST
fi

confirm() {
    if [[ "$UNATTENDED" = false ]]; then
        read -rp "Proceed with creating container $1? [y/N]: " answer
        [[ "$answer" =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

check_template_exists() {
    pct list | awk 'NR>1 {print $1}' | grep -q "^$1$"
}

wait_for_container() {
    local CTID="$1"
    local RETRIES=30
    local DELAY=2

    for ((i=1; i<=RETRIES; i++)); do
        if pct status "$CTID" | grep -q running; then
            return 0
        fi
        echo "[INFO] Waiting for container $CTID to start... ($i/$RETRIES)"
        sleep "$DELAY"
    done

    echo "[ERROR] Container $CTID failed to start after $((RETRIES * DELAY)) seconds."
    return 1
}

harden_ssh_config() {
    local CTID="$1"
    local SSH_CONFIG="/etc/ssh/sshd_config"
    local BACKUP_FILE="/etc/ssh/sshd_config.bak"

    echo "[INFO] Hardening SSH config for $CTID..."

    if ! pct exec "$CTID" -- dpkg -s openssh-server >/dev/null 2>&1; then
        pct exec "$CTID" -- apt-get update
        pct exec "$CTID" -- apt-get install -y openssh-server
    fi

    pct exec "$CTID" -- cp "$SSH_CONFIG" "$BACKUP_FILE"

    update_or_append() {
        local key="$1"
        local value="$2"
        local esc_value
        esc_value=$(echo "$value" | sed 's/[\\/&]/\\\\&/g')

        pct exec "$CTID" -- bash -c "
            grep -Eq '^#?\\s*$key\\s' $SSH_CONFIG \\
            && sed -i 's|^#\\?\\s*$key\\s\\+.*|$key $esc_value|' $SSH_CONFIG \\
            || echo '$key $esc_value' >> $SSH_CONFIG
        "
    }

    update_or_append "PasswordAuthentication" "no"
    update_or_append "PermitRootLogin" "prohibit-password"
    update_or_append "PubkeyAuthentication" "yes"
    update_or_append "MaxAuthTries" "3"
    update_or_append "LoginGraceTime" "20"
    update_or_append "ClientAliveInterval" "300"
    update_or_append "ClientAliveCountMax" "2"
    update_or_append "UseDNS" "no"
    update_or_append "X11Forwarding" "no"
    update_or_append "PermitEmptyPasswords" "no"
    update_or_append "LogLevel" "VERBOSE"

    if ! pct exec "$CTID" -- sshd -t; then
        echo "[ERROR] SSH config failed validation. Restoring backup..."
        pct exec "$CTID" -- cp "$BACKUP_FILE" "$SSH_CONFIG"
    else
        pct exec "$CTID" -- systemctl restart ssh || \
        pct exec "$CTID" -- service ssh restart || \
        pct exec "$CTID" -- /etc/init.d/ssh restart || true
        echo "[INFO] SSH config hardened for container $CTID"
    fi
}

exec_in_container() {
    local CTID="$1"; local CMD="$2"; local TIMEOUT=1800
    $DRY_RUN && echo "[DRY-RUN] Would run in $CTID: $CMD" && return 0
    timeout "$TIMEOUT" pct exec "$CTID" -- bash -c "$CMD"
}

add_authorized_keys_from_host() {
    local CTID="$1"
    local AUTH_KEYS_FILE="/root/.ssh/authorized_keys"
    if [[ -f "$AUTH_KEYS_FILE" ]]; then
        pct exec "$CTID" -- mkdir -p /root/.ssh
        pct push "$CTID" "$AUTH_KEYS_FILE" /root/.ssh/authorized_keys
        pct exec "$CTID" -- chmod 600 /root/.ssh/authorized_keys
        pct exec "$CTID" -- chown root:root /root/.ssh/authorized_keys
    fi
}

ensure_ssh_keypair() {
    local CTID="$1"
    local COMMENT
    COMMENT="$USER@$(hostname)"
    exec_in_container "$CTID" "
        mkdir -p /root/.ssh && chmod 700 /root/.ssh
        [ ! -f /root/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' -C '$COMMENT'
        [ ! -f /root/.ssh/id_ed25519 ] && ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N '' -C '$COMMENT'
        cat /root/.ssh/id_*.pub >> /root/.ssh/authorized_keys
        sort -u /root/.ssh/authorized_keys -o /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        chown root:root /root/.ssh/authorized_keys"
}

run_install_mode() {
    local CTID="$1"
    declare -a urls
    if [[ "$INSTALL_MODE" == "full" ]]; then
        urls=(
            "${INSTALL_SERVER_URL:-https://gist.githubusercontent.com/.../install-server-app.sh}"
            "${INSTALL_EXPORTER_URL:-https://gist.githubusercontent.com/.../install_exporter.sh}"
            "${SET_TIMEZONE_URL:-https://gist.githubusercontent.com/.../set_time_zone.sh}"
        )
    else
        urls=(
            "${INSTALL_MINI_PKGS_URL:-https://gist.githubusercontent.com/.../install_mini_packages.sh}"
            "${INSTALL_TMUX_URL:-https://gist.githubusercontent.com/.../install-tmux-debian.sh}"
            "${INSTALL_DOCKER_URL:-https://gist.githubusercontent.com/.../install-docker.sh}"
            "${INSTALL_ZSH_URL:-https://gist.githubusercontent.com/.../install-zsh.sh}"
            "${INSTALL_EXPORTER_URL:-https://gist.githubusercontent.com/.../install_exporter.sh}"
            "${SET_TIMEZONE_URL:-https://gist.githubusercontent.com/.../set_time_zone.sh}"
        )
    fi
    for url in "${urls[@]}"; do
        exec_in_container "$CTID" "wget -qO- $url | bash"
    done
}

clone_container() {
    local NAME="$1"
    $DRY_RUN && echo "[DRY-RUN] Would clone $NAME from template $TEMPLATE_ID" && return
    if ! confirm "$NAME"; then echo "[SKIPPED] $NAME"; return; fi
    if ! check_template_exists "$TEMPLATE_ID"; then
        echo "[ERROR] Template $TEMPLATE_ID does not exist"
        exit 1
    fi
    if pct list | awk 'NR>1 {print $2}' | grep -Fxq "$NAME"; then
        echo "[WARN] Name $NAME already exists. Skipping."
        return
    fi
    CTID=$(pvesh get /cluster/nextid)
    echo "[INFO] Cloning $NAME to CTID $CTID"
    pct clone "$TEMPLATE_ID" "$CTID" --hostname "$NAME" --full
    pct start "$CTID"
    wait_for_container "$CTID"
    add_authorized_keys_from_host "$CTID"
    ensure_ssh_keypair "$CTID"
    harden_ssh_config "$CTID"
    run_install_mode "$CTID"
    IP=$(pct exec "$CTID" -- hostname -I | awk '{print $1}')
    echo "$NAME,$CTID,$IP,$INSTALL_MODE" >> "$SUMMARY_FILE"
    echo "[DONE] $NAME (CTID $CTID) at $IP"
}

echo "[START] Cloning containers..."
echo "Name,CTID,IP,Mode" > "$SUMMARY_FILE"

for NAME in "${NAME_LIST[@]}"; do
    clone_container "$NAME"
done

echo "[COMPLETE] Summary at $SUMMARY_FILE"
column -s, -t "$SUMMARY_FILE"
