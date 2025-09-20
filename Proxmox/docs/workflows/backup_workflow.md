# Proxmox Backup Workflow

This document illustrates the workflow of the Proxmox backup system using Mermaid diagrams.

## Main Backup Process

```mermaid
flowchart TD
    A[Start Backup Process] --> B{Check OneDrive Mount}
    B -->|Not Mounted| C[Mount OneDrive]
    B -->|Already Mounted| D[Create Backup Directories]
    C --> D
    D --> E[Back Up Configuration Files]
    E --> F[Create Container/VM Snapshots with vzdump]
    F --> G[Copy Backups to Temporary Storage]
    G --> H[Sync to Primary Cloud Storage]
    H --> I[Sync to Secondary Cloud Storage]
    I --> J[Clean Up Old Local Backups]
    J --> K[Clean Up Old Cloud Backups]
    K --> L[Remove Temporary Files]
    L --> M[Send Completion Notification]
    M --> N[End Backup Process]

    %% Error handling
    C -->|Mount Failed| C1[Send Error Notification]
    C1 --> C2[Exit with Error]
    F -->|Snapshot Failed| F1[Send Error Notification] 
    F1 --> F2[Continue with Next Container]
    H -->|Sync Failed| H1[Send Error Notification]
    H1 --> I
```

## Backup File Management

```mermaid
flowchart LR
    A[Local VZ Dump] --> B[Find Files by Container ID]
    B --> C{Group & Sort by Date}
    C --> D[Keep 2 Most Recent Backups]
    D --> E[Delete Older Backups]

    F[Cloud Backups] --> G[List Backup Dates]
    G --> H{Sort by Date}
    H --> I[Keep 15 Most Recent Backups]
    I --> J[Delete Older Backups]
```

## Data Flow Architecture

```mermaid
flowchart TD
    A[Proxmox Node] --> B[Local Temporary Storage]
    B --> C[Local Backup Storage]
    B --> D[Primary Cloud Storage]
    D --> E[Secondary Cloud Storage]
    D --> F[Tertiary Cloud Storage]

    %% Storage types
    subgraph "Cloud Storage"
        D
        E
        F
    end
    
    subgraph "Local Storage"
        B
        C
    end
```

## Notification System

```mermaid
sequenceDiagram
    participant P as Proxmox Server
    participant S as Script Process
    participant T as Telegram Bot
    participant U as User

    S->>S: Start backup process
    S->>T: Send "Started backup" notification
    T->>U: Notify backup started
    
    S->>S: Execute backup steps
    
    alt Success
        S->>T: Send "Backup completed" notification
        T->>U: Notify backup success
    else Failure
        S->>T: Send "Backup failed" notification 
        T->>U: Notify backup failure
    end
```