# 💾 Proxmox Backup Server (PBS) 3-2-1 Chunk Deduplication Architecture

> **System Design Focus**: Chunk-Level Deduplicated, Client-Side Encrypted Backups for Homelab Fleets and LXC Containers.

---

## 💡 The Core Analogy: The Intelligent Library vs The Xerox Machine

> Traditional backup tools (like standard tarballs or raw `vzdump`) are like a photocopier: Every night, they copy the entire 20GB operating system over again, filling your storage drives with 99% identical duplicate data.
>
> **Proxmox Backup Server (PBS) is a shared content-addressed library**: PBS splits files into small, encrypted chunks (typically ~4MB). If a block of data has already been stored once by ANY container, PBS only stores a lightweight cryptographic pointer.
> 
> A daily backup of 15 containers takes **seconds instead of hours** and consumes **megabytes of new storage instead of gigabytes**.

---

## 🏗️ 3-2-1 Backup Topology

```mermaid
flowchart TD
    subgraph Primary_PVE["1️⃣ Primary Compute (Proxmox VE Node)"]
        CT1["15x LXC Containers"]
        Host["PVE Host Configurations (/etc/pve)"]
    end

    subgraph Secondary_PBS["2️⃣ Local Onsite Store (PBS Appliance / Dedicated LXC)"]
        PBS["Proxmox Backup Server (:8007)<br/><b>Chunk Deduplication Datastore</b><br/><i>Client-Side AES-GCM Encrypted</i>"]
        ZFS["Local ZFS Mirror Datastore"]
        PBS --> ZFS
    end

    subgraph Tertiary_Offsite["3️⃣ Offsite Cloud Sync (Disaster Recovery)"]
        Cloud["Remote Encrypted PBS / Cloud Store<br/><i>Rsync / Offsite Chunk Sync</i>"]
    end

    Primary_PVE -->|Encrypted Chunk Stream (pxar)| PBS
    PBS -->|Nightly Remote Sync Job| Cloud
```

---

## 🧠 The 3-Layer Cognitive Model (WHAT → HOW → WHY)

### 1. WHAT: The Architecture
- **Proxmox Backup Server (PBS)**: A dedicated enterprise-grade backup appliance. Can run on bare metal, dedicated VM, or inside an LXC container.
- **Client-Side Encryption (`--keyfile`)**: Data is encrypted using AES-GCM-256 on the client before leaving the machine. The PBS storage server cannot read your data.
- **Content-Addressed Chunks**: Every data chunk is addressed by its SHA-256 digest, providing native global deduplication across the entire fleet.

---

### 2. HOW: Automated Retention & Pruning Strategy

We enforce the **7-4-12 Retention Standard**:
- `--keep-daily 7`: Keep the last 7 daily snapshots.
- `--keep-weekly 4`: Keep the last 4 weekly snapshots (1 per week).
- `--keep-monthly 12`: Keep the last 12 monthly snapshots (1 per month).

---

### 3. WHY: Benefits in Homelab Practice

| Backup Method | Storage Consumption (15 Containers / 30 Days) | Backup Time | Encryption |
|:---|:---|:---|:---|
| **VZDump Full (`tar.zst`)** | ~450 GB – 800 GB | 15–30 minutes per run | Plaintext or server-side |
| **PBS Chunk Deduplication** | **~25 GB – 45 GB (95% saved)** | **10–40 seconds per run** | **Zero-Knowledge Client-Side AES-256** |
