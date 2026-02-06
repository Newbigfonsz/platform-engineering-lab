# 🐍🔥 Fire Snake Homelab - 3-2-1 Backup Strategy

Enterprise-grade backup solution for a Kubernetes homelab using Proxmox, Synology NAS, and Backblaze B2.

## Architecture Overview
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    PROXMOX      │────►│    SYNOLOGY     │────►│   BACKBLAZE     │
│   VMs (local)   │ NFS │   DS423 NAS     │rclone    B2 Cloud    │
│                 │     │   10.9TB SHR    │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
      Copy 1                 Copy 2                  Copy 3
    Production             On-premise               Off-site
```

## Backup Schedule

| Day | Time | Action | Location |
|-----|------|--------|----------|
| Sunday | 2:00 AM | Proxmox vzdump VMs → Synology NFS | Proxmox |
| Monday | 5:00 AM | Synology rclone sync → Backblaze B2 | Synology |

## Hardware

### Synology DS423
- **CPU:** Realtek RTD1619B (ARM64)
- **RAM:** 2GB (soldered)
- **Drives:** 4x Toshiba N300 4TB
- **RAID:** SHR (~10.9TB usable, 1-drive fault tolerance)

### Backed Up VMs
| VM ID | Name | Purpose |
|-------|------|---------|
| 103 | k8s-cp01 | Kubernetes Control Plane |
| 104 | k8s-worker01 | Kubernetes Worker |
| 105 | k8s-worker02 | Kubernetes Worker |

## Network

| Device | IP Address |
|--------|------------|
| Proxmox | 10.10.0.210 |
| Synology | 10.10.0.203 |

## Synology NFS Configuration
```
Export: /volume1/proxmox-backups
Client: 10.10.0.210
Privilege: Read/Write
Squash: Map root to admin
```

## Proxmox Backup Script

**Location:** `/root/backup-vms.sh`
```bash
#!/bin/bash
vzdump 103 104 105 --storage synology-backups --compress zstd --mode snapshot --prune-backups keep-last=4
```

## rclone B2 Sync (Synology)
```bash
sudo rclone sync /volume1/proxmox-backups/dump b2:homelab-backups-firesnake/proxmox-backups --progress
```

## Retention
- **Synology:** Last 4 backups (Proxmox prune)
- **B2:** Mirrors Synology (rclone sync)

## Monthly Cost
~$0.25 (Backblaze B2 storage for ~37GB)

## Disaster Recovery

### Restore from Synology
1. Proxmox UI → synology-backups storage
2. Select backup → Restore

### Restore from B2
```bash
# On Synology
sudo rclone copy b2:homelab-backups-firesnake/proxmox-backups/[backup-file] /volume1/proxmox-backups/dump/
```
Then restore via Proxmox UI.
