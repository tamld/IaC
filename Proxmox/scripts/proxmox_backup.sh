#!/usr/bin/env bash
set -euo pipefail

# Load environment variables and helpers
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Preserve env-provided values to keep precedence over .env for key paths
_ENV_MOUNT_POINT="${MOUNT_POINT:-}"
_ENV_VZ_BACKUP_DIR="${VZ_BACKUP_DIR:-}"
_ENV_VZ_TEMP_BACKUP_DIR="${VZ_TEMP_BACKUP_DIR:-}"
_ENV_ROOT_TEMP_BACKUP_DIR="${ROOT_TEMP_BACKUP_DIR:-}"
_ENV_TEMP_BACKUP_DIR="${TEMP_BACKUP_DIR:-}"
_ENV_TEMPLATE_CACHE_DIR="${TEMPLATE_CACHE_DIR:-}"
_ENV_SNIPPETS_DIR="${SNIPPETS_DIR:-}"
_ENV_ISO_DIR="${ISO_DIR:-}"
_ENV_SCRIPTS_DIR="${SCRIPTS_DIR:-}"
_ENV_PRIMARY_BACKUP_DRIVE="${PRIMARY_BACKUP_DRIVE:-}"
_ENV_SECONDARY_BACKUP_DRIVE="${SECONDARY_BACKUP_DRIVE:-}"
_ENV_THIRD_BACKUP_DRIVE="${THIRD_BACKUP_DRIVE:-}"
_ENV_BACKUP_DIR="${BACKUP_DIR:-}"

# Prefer project-level .env; fallback to script-local or system path (but do not override env)
for ENV_CAND in "$PROJECT_ROOT/.env" "$SCRIPT_DIR/.env" "/root/scripts/.env"; do
  if [ -f "$ENV_CAND" ]; then
    # shellcheck disable=SC1090
    . "$ENV_CAND"; break
  fi
done

# Re-apply env-precedence values if they were set
[ -n "$_ENV_MOUNT_POINT" ] && MOUNT_POINT="$_ENV_MOUNT_POINT"
[ -n "$_ENV_VZ_BACKUP_DIR" ] && VZ_BACKUP_DIR="$_ENV_VZ_BACKUP_DIR"
[ -n "$_ENV_VZ_TEMP_BACKUP_DIR" ] && VZ_TEMP_BACKUP_DIR="$_ENV_VZ_TEMP_BACKUP_DIR"
[ -n "$_ENV_ROOT_TEMP_BACKUP_DIR" ] && ROOT_TEMP_BACKUP_DIR="$_ENV_ROOT_TEMP_BACKUP_DIR"
[ -n "$_ENV_TEMP_BACKUP_DIR" ] && TEMP_BACKUP_DIR="$_ENV_TEMP_BACKUP_DIR"
[ -n "$_ENV_TEMPLATE_CACHE_DIR" ] && TEMPLATE_CACHE_DIR="$_ENV_TEMPLATE_CACHE_DIR"
[ -n "$_ENV_SNIPPETS_DIR" ] && SNIPPETS_DIR="$_ENV_SNIPPETS_DIR"
[ -n "$_ENV_ISO_DIR" ] && ISO_DIR="$_ENV_ISO_DIR"
[ -n "$_ENV_SCRIPTS_DIR" ] && SCRIPTS_DIR="$_ENV_SCRIPTS_DIR"
[ -n "$_ENV_PRIMARY_BACKUP_DRIVE" ] && PRIMARY_BACKUP_DRIVE="$_ENV_PRIMARY_BACKUP_DRIVE"
[ -n "$_ENV_SECONDARY_BACKUP_DRIVE" ] && SECONDARY_BACKUP_DRIVE="$_ENV_SECONDARY_BACKUP_DRIVE"
[ -n "$_ENV_THIRD_BACKUP_DRIVE" ] && THIRD_BACKUP_DRIVE="$_ENV_THIRD_BACKUP_DRIVE"
[ -n "$_ENV_BACKUP_DIR" ] && BACKUP_DIR="$_ENV_BACKUP_DIR"
[ -f "$SCRIPT_DIR/common.sh" ] && . "$SCRIPT_DIR/common.sh"
# shellcheck source=common.sh

# Capacity threshold for backup destinations
# Default MIN_FREE to 50G if not set in environment (.env). Change here or via .env to adjust.
MIN_FREE="${MIN_FREE:-50G}"

# Dry-run for CI/testing: when set to 1, skip heavy operations and simulate outputs
BACKUP_DRY_RUN="${BACKUP_DRY_RUN:-0}"

# Ensure a writable log file path (fallback to /tmp if not provided)
DATE="${DATE:-$(date +%F)}"
LOG_FILE="${LOG_FILE:-/tmp/proxmox_backup_${DATE}.log}"

# log_message and send_telegram come from common.sh

# Function to create necessary directories before backup
create_backup_dirs() {
    log_message "Creating necessary directories..."

    # Array of directories to ensure they exist
    local dirs_to_create=(
        "$MOUNT_POINT"               # OneDrive mount point
        #"$MOUNT_POINT_BACKUP_DIR"    # Directory within online drive mount for storing backup files
        #"$VZ_MOUNT_POINT"            # vzdump mount point
        "$VZ_BACKUP_DIR"             # Directory where Proxmox stores local container backups
        "$VZ_TEMP_BACKUP_DIR"        # Temporary vzdump files
        "$ROOT_TEMP_BACKUP_DIR"      # Root-level temporary backup directory
        "$TEMP_BACKUP_DIR"           # General temporary backup directory
        "$TEMPLATE_CACHE_DIR"        # Template cache directory
        "$SNIPPETS_DIR"              # Template Cloud Init
        "$ISO_DIR"                   # ISO directory
        "$SCRIPTS_DIR"               # Directory where additional scripts, including this backup script, are stored
    )

    # Loop through each directory and create it if it doesn't exist
    for dir in "${dirs_to_create[@]}"; do
        # Check if the directory exists before trying to create it
        if [[ ! -d "$dir" ]]; then
            log_message "Creating directory $dir..."
            mkdir -p "$dir" || log_message "Failed to create $dir."
        else
            log_message "Directory $dir already exists."
        fi
    done

    log_message "Directories created successfully."
}

cleanup_old_vzdump_files() {
    log_message "Running centralized retention cleanup (keep ${VZ_KEEP:-2}) on $VZ_BACKUP_DIR"
    if [ -x "$SCRIPT_DIR/clean_old_vzdump.sh" ]; then
        VZ_BACKUP_DIR="$VZ_BACKUP_DIR" "$SCRIPT_DIR/clean_old_vzdump.sh" --unattended --keep "${VZ_KEEP:-2}" || true
    else
        log_message "clean_old_vzdump.sh not found or not executable; skipping centralized cleanup."
    fi
}

# Function to clean up old backups on OneDrive, keeping only the 15 most recent
cleanup_onedrive_backups() {
    if [[ "${BACKUP_DRY_RUN:-0}" == "1" ]]; then
        log_message "[DRY-RUN] Skipping cloud retention cleanup"
        return
    fi
    log_message "Cleaning up old backups on OneDrive, keeping only the 15 most recent..."
    cd "$BACKUP_DIR" || exit
    for dir in */; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f \( -name '*.tar.gz' -o -name '*.vma.gz' -o -name '*.vma.zst' \) -printf '%T@ %p\n' | sort -n | awk 'NR>15 {print $2}' | xargs -r rm -- 
        fi
    done
    log_message "OneDrive backup cleanup completed."
}

# Check if OneDrive is already mounted, and mount if necessary
check_and_mount_onedrive() {
    if [[ "$BACKUP_DRY_RUN" == "1" ]]; then
        log_message "[DRY-RUN] Skipping mount checks"
        return
    fi
    # Check if fuse3 is installed, if not, install it
    if ! command -v fusermount3 &> /dev/null; then
        log_message "fuse3 is not installed. Installing fuse3..."
        if ! apt update && apt install -y fuse3; then
            log_message "Failed to install fuse3. Exiting."
            send_telegram "🔴 Failed to install fuse3 for $(hostname) on $DATE."
            exit 1
        fi
        log_message "fuse3 installed successfully."
    fi

    # Check if OneDrive is already mounted
    if mount | grep "$MOUNT_POINT" > /dev/null; then
        log_message "OneDrive is already mounted."
    else
        log_message "Mounting OneDrive..."
        
        # Unmount in case there is an old mount lingering
        fusermount -u "$MOUNT_POINT" 2>/dev/null
        
        # Attempt to mount OneDrive
        if ! rclone mount "$PRIMARY_BACKUP_DRIVE" "$MOUNT_POINT" --daemon --allow-non-empty --vfs-cache-mode writes -vv; then
            log_message "Failed to mount OneDrive. Exiting."
            send_telegram "🔴 Failed to mount OneDrive for $(hostname) on $DATE."
            exit 1
        fi
        log_message "OneDrive mounted successfully."
    fi
}

# Function to clean up temporary backup files
cleanup_temp_files() {
    log_message "Cleaning up temporary backup files in $VZ_MOUNT_POINT/$DATE..."
    rm -rf "$ROOT_TEMP_BACKUP_DIR" 2>/dev/null || log_message "No temporary files to clean up."
}

# Function to perform the backup
perform_backup() {
    log_message "Starting configuration backups..."
    
    # Create a directory for backups (temporary backup directory for the current day)
    mkdir -p "$TEMP_BACKUP_DIR" || log_message "Failed to create backup dir"
    
	# Copy template data to OneDrive
    log_message "Copying template data to OneDrive..."
	echo "Copying template data to OneDrive..."
    rclone_copy "$TEMPLATE_CACHE_DIR" "$PRIMARY_BACKUP_DRIVE/template/cache"
    rclone_copy "$ISO_DIR" "$PRIMARY_BACKUP_DRIVE/template/iso"
	rclone_copy "$SCRIPTS_DIR" "$PRIMARY_BACKUP_DRIVE/scripts"
    # Paths to compress, including new configurations
    local paths_to_backup=( 
        "/etc/pve"
        "/etc/network"
        "/etc/pve/storage.cfg"
        "/etc/pve/user.cfg"
    )

    # Compress configuration files (simulate if dry-run)
    for path in "${paths_to_backup[@]}"; do
        # Use sanitized path as name, e.g., /etc/pve -> etc.pve.tar
        local name_sanitized
        name_sanitized=$(echo "$path" | sed 's#^/##; s#/#.#g')
        local tar_file="$TEMP_BACKUP_DIR/${name_sanitized}.tar"
        if [[ "$BACKUP_DRY_RUN" == "1" ]]; then
            log_message "[DRY-RUN] Would compress $path to $tar_file"
            echo "SIMULATED TAR for $path" > "$tar_file"
        else
            log_message "Compressing $path to $tar_file..."
            tar -cvf "$tar_file" "$path" 2>/dev/null || log_message "Failed to compress $path."
        fi
    done

    # Prepare list of remotes for multi-drive copy
    local remotes_list=""
    for r in "$PRIMARY_BACKUP_DRIVE" "$SECONDARY_BACKUP_DRIVE" "${THIRD_BACKUP_DRIVE:-}"; do
        [[ -n "$r" ]] && remotes_list+="${remotes_list:+,}$r"
    done
    export BACKUP_REMOTES="$remotes_list"

    # Prepare min-free argument (default 50G, overridable via .env)
    local min_args=( --min-free "$MIN_FREE" )

    # Copy compressed configuration files to online backup remotes under $DATE
    log_message "Copying configuration backup files to online remotes..."
    local dry_args=()
    [[ "$BACKUP_DRY_RUN" == "1" ]] && dry_args=( --dry-run )
    bash "$SCRIPT_DIR/multi_drive_backup.sh" --source "$TEMP_BACKUP_DIR" --dest-subpath "$DATE" --op copy --min-online 1 --mode proceed "${min_args[@]}" "${dry_args[@]}"
	
	# Copy dump files to OneDrive under the $DATE directory
	echo "Starting vzdump backup for all VMs and containers to \"$TEMP_BACKUP_DIR\""
    if [[ "$BACKUP_DRY_RUN" == "1" ]]; then
        mkdir -p "$VZ_TEMP_BACKUP_DIR"
        echo "SIMULATED VZDUMP" > "$VZ_TEMP_BACKUP_DIR/vzdump-lxc-101-$DATE-00_00_00.tar.zst"
    else
        #vzdump --mode snapshot --compress gzip --all --quiet --dumpdir "$VZ_BACKUP_DIR"
        vzdump --mode snapshot --compress zstd --all --dumpdir "$VZ_TEMP_BACKUP_DIR"
    fi
	echo "Copy from \"$VZ_TEMP_BACKUP_DIR\" to \"$VZ_BACKUP_DIR\""
	cp -r "$VZ_TEMP_BACKUP_DIR" "$VZ_BACKUP_DIR"
    # Copy vzdump artifacts to online remotes under $DATE/vzdump
    echo "Copy vzdump artifacts to online remotes under $DATE/vzdump"
    bash "$SCRIPT_DIR/multi_drive_backup.sh" --source "$VZ_TEMP_BACKUP_DIR" --dest-subpath "$DATE/vzdump" --op copy --min-online 1 --mode proceed "${min_args[@]}" "${dry_args[@]}"
    log_message "Backup completed."
}

# rclone copy function for backup files with detailed Telegram notifications
rclone_copy() {
    local source_path="$1"
    local destination_path="$2"

    log_message "Starting copy from $source_path to $destination_path..."

    if rclone copy "$source_path" "$destination_path" -v --progress --checksum --checkers 10 --transfers 10 --drive-server-side-across-configs --copy-links; then
        log_message "Copied $source_path to $destination_path"
    else
        log_message "Failed to copy $source_path to $destination_path"
        send_telegram "🔴 Failed to copy $source_path to $destination_path"
    fi
}

# rclone sync function for syncing directories with detailed logging and notifications
rclone_sync() {
    local source_path="$1"
    local destination_path="$2"
    
    log_message "Starting sync from $source_path to $destination_path..."

    # Use rclone sync with additional options for robustness, including --delete-after
    if rclone sync "$source_path" "$destination_path" -v --progress --checksum --checkers 10 --transfers 10 --drive-server-side-across-configs --copy-links --delete-after; then
        log_message "Successfully synced $source_path to $destination_path"
    else
        log_message "Failed to sync $source_path to $destination_path"
        send_telegram "🔴 Failed to sync from $source_path to $destination_path"
    fi

    log_message "Sync operation completed for $source_path."
}

# Function to sync backups to secondary OneDrive using rclone_sync
sync_to_secondary() { :; }

# Notify start of backup
send_telegram "🟢 Starting daily Proxmox backup for $(hostname) on $DATE."

# Create necessary directories
create_backup_dirs

# Check and mount OneDrive
check_and_mount_onedrive

# Run inside a lock to avoid concurrent runs
# Prefer lock if flock is available; otherwise run without lock (CI/macOS compatibility)
if command -v flock >/dev/null 2>&1; then
  if command -v with_lock >/dev/null 2>&1; then
    with_lock "/var/lock/proxmox_backup.lock" perform_backup
  else
    perform_backup
  fi
else
  perform_backup
fi

# Cleanup old local vzdump files
cleanup_old_vzdump_files

# Cleanup old backups on OneDrive
cleanup_onedrive_backups

# Cleanup temporary files
cleanup_temp_files
# Notify completion of backup
send_telegram "✅ Proxmox backup completed successfully for Node:$(hostname) on $DATE."
