#!/usr/bin/env bash
set -euo pipefail

########################################
# Teleport Agent Deployment for Proxmox Containers (PCT)
#
# Features
# - Attended mode with interactive prompts
# - Unattended mode via CLI flags
# - Parameterised auth server (no hard-coded IPs)
#
# Usage Examples:
#   ./deploy_teleport_agent.sh \
#       --token "${TELEPORT_TOKEN}" \
#       --ca-pin "sha256:..." \
#       --auth-server teleport.example.lab:3025 \
#       --vmid 101 102
########################################

TELEPORT_TOKEN="${TELEPORT_TOKEN:-}"
TELEPORT_CA_PIN="${TELEPORT_CA_PIN:-}"
TELEPORT_AUTH_SERVER="${TELEPORT_AUTH_SERVER:-}"
VMID_LIST=()
ATTENDED=1

usage() {
    cat <<USAGE
Usage: $0 [options]

Options:
  -t, --token VALUE           Teleport join token
  -c, --ca-pin VALUE          Teleport CA pin (sha256:...)
  -a, --auth-server HOST:PORT Teleport auth server address
  -v, --vmid LIST             One or more CTIDs (space separated)
  -h, --help                  Show this help message

Environment:
  TELEPORT_TOKEN        Default token if flag omitted
  TELEPORT_CA_PIN       Default CA pin if flag omitted
  TELEPORT_AUTH_SERVER  Default auth server (e.g., teleport.example.lab:3025)
USAGE
    exit 0
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--token)
                TELEPORT_TOKEN="${2:-}"; shift 2 ;;
            -c|--ca-pin)
                TELEPORT_CA_PIN="${2:-}"; shift 2 ;;
            -a|--auth-server)
                TELEPORT_AUTH_SERVER="${2:-}"; shift 2 ;;
            -v|--vmid)
                shift
                while [[ $# -gt 0 && "$1" != -* ]]; do
                    VMID_LIST+=("$1")
                    shift
                done
                ATTENDED=0
                ;;
            -h|--help)
                usage ;;
            *)
                echo "[ERROR] Unknown option: $1" >&2
                usage ;;
        esac
    done
}

attended_prompt() {
    echo "📦 Available containers:"
    pct list
    echo
    read -rp "Enter one or more VMIDs (space separated): " -a VMID_LIST

    read -rsp "🔑 Enter Teleport token: " TELEPORT_TOKEN; echo
    read -rsp "📌 Enter Teleport CA pin (sha256:...): " TELEPORT_CA_PIN; echo
    read -rp "🌐 Teleport auth server [host:port]: " TELEPORT_AUTH_SERVER
}

validate_inputs() {
    local missing=()
    [[ -z "$TELEPORT_TOKEN" ]] && missing+=("token")
    [[ -z "$TELEPORT_CA_PIN" ]] && missing+=("ca-pin")
    [[ -z "$TELEPORT_AUTH_SERVER" ]] && missing+=("auth-server")
    [[ ${#VMID_LIST[@]} -eq 0 ]] && missing+=("vmid")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "[ERROR] Missing required values: ${missing[*]}" >&2
        exit 1
    fi

    if ! grep -q ':' <<<"$TELEPORT_AUTH_SERVER"; then
        echo "[ERROR] auth-server must be in HOST:PORT form" >&2
        exit 1
    fi
}

validate_vmids() {
    local actual_ids
    actual_ids=$(pct list | awk 'NR>1 {print $1}')
    for vmid in "${VMID_LIST[@]}"; do
        if ! grep -qw "$vmid" <<<"$actual_ids"; then
            echo "[ERROR] VMID $vmid not found" >&2
            exit 1
        fi
    done
}

install_agent() {
    local ctid="$1"
    echo "[INFO] Deploying Teleport to CTID $ctid"
    pct exec "$ctid" -- bash -c "
        set -e
        echo '[+] Installing Teleport dependencies...'
        apt-get update -qq
        apt-get install -y curl gnupg2 apt-transport-https ca-certificates software-properties-common -qq

        echo '[+] Adding Teleport repository...'
        curl https://deb.releases.teleport.dev/teleport-pubkey.asc | gpg --dearmor > /usr/share/keyrings/teleport-archive-keyring.gpg
        echo 'deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.gpg] https://deb.releases.teleport.dev/ stable main' > /etc/apt/sources.list.d/teleport.list
        apt-get update -qq
        apt-get install -y teleport -qq

        echo '[+] Writing Teleport config...'
        mkdir -p /etc
        cat > /etc/teleport.yaml <<'CFG'
teleport:
  nodename: \$(hostname)
  auth_token: __TELEPORT_TOKEN__
  ca_pin: __TELEPORT_CA_PIN__
  auth_servers:
    - __TELEPORT_AUTH_SERVER__
  log:
    output: /var/log/teleport.log
    severity: INFO

ssh_service:
  enabled: yes

auth_service:
  enabled: no

proxy_service:
  enabled: no
CFG
        sed -i "s#__TELEPORT_TOKEN__#${TELEPORT_TOKEN}#" /etc/teleport.yaml
        sed -i "s#__TELEPORT_CA_PIN__#${TELEPORT_CA_PIN}#" /etc/teleport.yaml
        sed -i "s#__TELEPORT_AUTH_SERVER__#${TELEPORT_AUTH_SERVER}#" /etc/teleport.yaml

        echo '[+] Enabling Teleport service...'
        systemctl enable teleport
        systemctl restart teleport

        echo '✅ Teleport agent deployed to CTID ${ctid}'
    "
}

main() {
    parse_arguments "$@"
    [[ $ATTENDED -eq 1 ]] && attended_prompt
    validate_inputs
    validate_vmids

    echo "[INFO] Deploying Teleport to: ${VMID_LIST[*]}"
    for vmid in "${VMID_LIST[@]}"; do
        install_agent "$vmid"
    done
    echo "🚀 Deployment completed"
}

main "$@"
