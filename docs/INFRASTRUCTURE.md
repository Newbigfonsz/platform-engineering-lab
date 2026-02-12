# Infrastructure & Reliability

## Power Protection

### UPS: CyberPower CST150UC2 (1500VA / 900W)

**Connected Equipment:**
- Proxmox host (Dell T3600)
- Network switch
- Router/modem
- k8s-worker03 (bare metal)
- k8s-worker04 (bare metal)

**Monitoring:**
- NUT (Network UPS Tools) on Proxmox
- Discord alerts for power events
- Auto-shutdown at 10% battery

**Runtime:** ~60 minutes at typical load (~15%)

### NUT Configuration (Proxmox)

| File | Purpose |
|------|---------|
| `/etc/nut/ups.conf` | UPS driver config |
| `/etc/nut/upsmon.conf` | Monitoring & shutdown |
| `/etc/nut/upsd.users` | Auth config |
| `/usr/local/bin/ups-notify.sh` | Discord alerts |

**Commands:**
```bash
# Check UPS status
upsc cyberpower@localhost

# Quick status
upsc cyberpower@localhost ups.status battery.charge battery.runtime

# Test Discord alert
/usr/local/bin/ups-notify.sh online
```

**Status Codes:**
- `OL` = Online (AC power)
- `OB` = On Battery
- `LB` = Low Battery

---

## Hardware Watchdog

All nodes have hardware watchdog enabled for auto-reboot on system hang.

**Configuration:**
```
# /etc/systemd/system.conf
RuntimeWatchdogSec=15
ShutdownWatchdogSec=10min
```

**Kernel Module:** `iTCO_wdt` (Intel TCO Watchdog)

---

## NIC Stability (e1000e Fix)

Intel NICs on bare metal nodes have known hang issues. Fixed by disabling offloads.

**Affected Nodes:**
- Proxmox (10.10.0.210)
- k8s-worker03 (10.10.0.113)
- k8s-worker04 (10.10.0.114)
- k8s-worker05 (10.10.0.115)

**Fix Applied:**
```bash
# Systemd service: /etc/systemd/system/e1000e-fix.service
# Script: /usr/local/bin/e1000e-fix.sh
# Disables: TSO, GSO, GRO
```

---

## SMART Monitoring

Disk health monitoring on all bare metal nodes.

**Package:** `smartmontools`
**Service:** `smartd`

**Check disk health:**
```bash
sudo smartctl -a /dev/sda
```

---

## Discord Alerts

| Alert | Trigger |
|-------|---------|
| Power Outage | UPS switches to battery |
| Power Restored | UPS back on AC |
| Low Battery | Battery < 20% |
| SMART Failure | Disk errors detected |
| Daily Health | 8 AM daily cluster status |

**Webhook configured on:**
- Proxmox (UPS alerts)
- k8s-cp01 (Daily health check)

---

## Backup Schedule

| Backup | Schedule | Retention | Location |
|--------|----------|-----------|----------|
| etcd snapshots | Daily 2 AM | 7 days | k8s-cp01:/home/ubuntu/etcd-backups/ |
| Velero (K8s) | Daily | 30 days | Synology → Backblaze B2 |
| Proxmox VMs | Weekly | 4 weeks | Synology NAS |

---

## Network Topology
```
Internet
    │
    ▼
Cloudflare Tunnel
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                   10.10.0.0/24                       │
│                                                      │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐         │
│  │ Proxmox │    │ Synology│    │  Router │         │
│  │  .210   │    │  .203   │    │   .1    │         │
│  └────┬────┘    └─────────┘    └─────────┘         │
│       │                                             │
│  ┌────┴────────────────────────────────────┐       │
│  │         Kubernetes Cluster               │       │
│  │  VIP: 10.10.0.100 (kube-vip)            │       │
│  │                                          │       │
│  │  cp01    worker01  worker02  (VMs)      │       │
│  │  .103    .104      .105                 │       │
│  │                                          │       │
│  │  worker03  worker04  worker05 (Bare)    │       │
│  │  .113      .114      .115               │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
```

---

## Quick Reference

| Component | IP/URL | Access |
|-----------|--------|--------|
| Proxmox | 10.10.0.210:8006 | root |
| K8s VIP | 10.10.0.100:6443 | kubectl |
| k8s-cp01 | 10.10.0.103 | ubuntu |
| k8s-worker05 | 10.10.0.115 | bigfonsz |
| Synology | 10.10.0.203 | admin |
