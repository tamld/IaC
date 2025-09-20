# PCT Backup and Restoration Guide

This knowledge base article explains the Proxmox Container Templates (PCT) backup and restoration process in detail.

## Understanding PCT Backup

Proxmox Container Templates (PCT) are pre-configured LXC container templates that serve as the foundation for deploying new containers. Backing them up properly ensures you can quickly redeploy containers and recover from failures.

### Key Components

1. **Container Configuration**
   - Located in `/etc/pve/lxc/CTID.conf`
   - Contains network settings, resource limits, mount points, etc.

2. **Container Filesystem**
   - Located in the storage defined in the configuration
   - Usually `/var/lib/vz/private/CTID` for local storage

3. **Templates**
   - Cached in `/var/lib/vz/template/cache/`
   - Used to create new containers

## Backup Methods

### 1. Full Backup with vzdump

The `vzdump` command creates comprehensive backups of containers including:
- Container configuration
- Complete filesystem
- Metadata

```bash
vzdump CTID --mode snapshot --compress zstd --dumpdir /path/to/backup
```

Parameters:
- `--mode snapshot`: Creates a snapshot to backup running containers without stopping them
- `--compress zstd`: Uses zstd compression for better performance/compression ratio
- `--dumpdir`: Directory where backup files are stored

### 2. Configuration-Only Backup

For just backing up configurations without the full container data:

```bash
tar -cvf /backup/pve_config.tar /etc/pve
```

This captures all Proxmox configurations, including container settings.

## Restoration Process

### 1. Restoring from vzdump Backup

```bash
pct restore CTID /path/to/backup/vzdump-lxc-CTID-TIMESTAMP.tar.zst --storage STORAGE
```

Parameters:
- `CTID`: The ID for the restored container (can be different from original)
- `--storage`: Target storage for the restored container

### 2. Restoring Configuration Only

If you need to restore just the configuration:

```bash
tar -xvf /backup/pve_config.tar -C /
```

## Backup Retention Strategy

Our system implements an intelligent retention strategy:

1. **Local Storage**
   - Keep at least 2 most recent backups per container
   - Automatically remove older backups

2. **Cloud Storage**
   - Keep at least 15 most recent backups
   - Organized by date in folder structure

## Best Practices

1. **Regular Testing**
   - Periodically test restoring containers from backups
   - Verify application functionality post-restore

2. **Off-Site Storage**
   - Always maintain backups in at least two physically separated locations
   - Use rclone to synchronize with cloud storage

3. **Encryption**
   - Use encrypted storage for sensitive container data
   - Consider rclone's encryption capabilities for cloud backups

4. **Documentation**
   - Keep detailed records of container configurations
   - Document special requirements for each container

## Troubleshooting

### Common Restoration Issues

1. **Storage Not Found**
   - Ensure the target storage exists and has sufficient space
   - Check storage configuration in `/etc/pve/storage.cfg`

2. **Permission Issues**
   - Verify the backup files have correct permissions
   - Run restore commands as root

3. **Network Configuration Conflicts**
   - Check for IP address conflicts after restore
   - May need to modify network configuration post-restore

4. **Resource Constraints**
   - Ensure the Proxmox host has sufficient resources for the restored container
   - Adjust resource limits if needed