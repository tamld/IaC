#!/usr/bin/env bash
set -e

########################################
# VARIABLE: Template ID
########################################
PCT_TEMPLATE_ID=8003

########################################
# Function: wait_for_container
#  - Waits until the given container is 'running' or times out.
########################################
wait_for_container() {
    local CTID="$1"
    local MAX_RETRIES=60
    local RETRY=0

    while [ $RETRY -lt $MAX_RETRIES ]; do
        if pct status "$CTID" | grep -q running; then
            return 0
        fi
        echo "[INFO] Waiting for container $CTID to start... (attempt $((RETRY + 1))/$MAX_RETRIES)"
        sleep 5
        (( RETRY++ ))
    done
    return 1
}

########################################
# Function: exec_in_container
#  - Executes a command in the container with a timeout.
########################################
exec_in_container() {
    local CTID="$1"
    local CMD="$2"
    local TIMEOUT=1800  # 30 minutes

    timeout "$TIMEOUT" pct exec "$CTID" -- /bin/bash -c "$CMD"
    local EXIT_CODE=$?

    if [ $EXIT_CODE -eq 124 ]; then
        echo "[ERROR] Command timed out after $TIMEOUT seconds: $CMD"
        return 1
    elif [ $EXIT_CODE -ne 0 ]; then
        echo "[ERROR] Command failed with exit code $EXIT_CODE: $CMD"
        return 1
    fi
    return 0
}

########################################
# Function: add_authorized_keys
#  - Copies /root/.ssh/authorized_keys from host to container, if it exists.
########################################
add_authorized_keys() {
    local CTID="$1"
    local AUTH_KEYS_FILE="/root/.ssh/authorized_keys"

    if [ -f "$AUTH_KEYS_FILE" ]; then
        pct exec "$CTID" -- mkdir -p /root/.ssh
        pct push "$CTID" "$AUTH_KEYS_FILE" /root/.ssh/authorized_keys
        pct exec "$CTID" -- chmod 600 /root/.ssh/authorized_keys
        pct exec "$CTID" -- chown root:root /root/.ssh/authorized_keys
        echo "[INFO] authorized_keys has been copied to container $CTID."
    else
        echo "[WARNING] No authorized_keys found at $AUTH_KEYS_FILE. Skipping."
    fi
}

########################################
# Function: get_container_ip
#  - Retrieves the container's first non-loopback IP address.
########################################
get_container_ip() {
    local CTID="$1"
    pct exec "$CTID" -- ip a \
      | grep -oP '(?<=inet\s)\d+(\.\d+){3}' \
      | grep -v '^127\.' \
      | head -n 1
}

########################################
# GLOBALS for argument logic
# HOSTNAME     => container hostname
# INSTALL_MODE => "ask", "full", or "minimal"
# ATTENDED     => 1 if no arguments were passed => prompt user
########################################
HOSTNAME=""
INSTALL_MODE="ask"
ATTENDED=1

########################################
# Function: parse_arguments
#  - If no arguments => attended mode (prompts).
#  - If arguments => read <hostname>, then --full/-f or --minimal/-m.
########################################
parse_arguments() {
    # If no args => we prompt
    if [ $# -eq 0 ]; then
        ATTENDED=1
        return
    fi

    # Otherwise, no prompting
    ATTENDED=0
    HOSTNAME="$1"
    shift

    while [ $# -gt 0 ]; do
        case "$1" in
            --full|-f)
                INSTALL_MODE="full"
                shift
                ;;
            --minimal|-m)
                INSTALL_MODE="minimal"
                shift
                ;;
            *)
                echo "[ERROR] Unknown argument: $1"
                echo "Usage: $0 [<hostname> [--full|-f | --minimal|-m]]"
                exit 1
                ;;
        esac
    done
}

########################################
# Function: main_logic
#  - Clones and starts a new container, installs requested apps.
########################################
main_logic() {
    # If we are in attended mode => prompt user
    if [ "$ATTENDED" -eq 1 ]; then
        read -p "Enter the hostname for the new container: " HOSTNAME
        if [ -z "$HOSTNAME" ]; then
            echo "[ERROR] Hostname cannot be empty."
            exit 1
        fi

        read -p "Do you want to install the full app? (yes/YES/y to confirm): " REPLY_MODE
        REPLY_MODE=$(echo "$REPLY_MODE" | tr '[:upper:]' '[:lower:]')
        if [[ "$REPLY_MODE" == "yes" || "$REPLY_MODE" == "y" ]]; then
            INSTALL_MODE="full"
        else
            INSTALL_MODE="minimal"
        fi
    fi

    echo "[INFO] Listing available containers..."
    pct list

    # Get next CTID
    NEXT_CTID=$(pvesh get /cluster/nextid)
    echo "[INFO] Next available CTID: $NEXT_CTID"

    # Clone
    echo "[INFO] Cloning container from template $PCT_TEMPLATE_ID to CTID $NEXT_CTID with hostname '$HOSTNAME'..."
    pct clone "$PCT_TEMPLATE_ID" "$NEXT_CTID" --hostname "$HOSTNAME" --full

    # Start container
    echo "[INFO] Starting container $NEXT_CTID..."
    pct start "$NEXT_CTID"
    if ! wait_for_container "$NEXT_CTID"; then
        echo "[ERROR] Container $NEXT_CTID failed to start within the timeout."
        exit 1
    fi

    # Add authorized_keys
    add_authorized_keys "$NEXT_CTID"

    # Install based on mode
    if [ "$INSTALL_MODE" = "full" ]; then
        echo "[INFO] Installing FULL apps on container $NEXT_CTID..."
        exec_in_container "$NEXT_CTID" 'wget -qO- tinyurl.com/tamld-server-apps | bash'
    else
        echo "[INFO] Installing MINIMAL apps (zsh, tmux) on container $NEXT_CTID..."
        exec_in_container "$NEXT_CTID" 'wget -qO- tinyurl.com/tamld-zsh | bash'
        exec_in_container "$NEXT_CTID" 'wget -qO- tinyurl.com/tamld-tmux | bash'
    fi

    # Get IP
    local CONTAINER_IP
    CONTAINER_IP=$(get_container_ip "$NEXT_CTID")

    echo "========================================"
    echo "[INFO] Container $NEXT_CTID setup completed."
    echo "[INFO] Hostname    : $HOSTNAME"
    echo "[INFO] IP Address  : $CONTAINER_IP"
    echo "[INFO] Install Mode: $INSTALL_MODE"
    echo "========================================"
}

########################################
# Main function
########################################
main() {
    # 1) Parse arguments for attended/unattended
    parse_arguments "$@"

    # 2) Run main logic
    main_logic
}

main "$@"
