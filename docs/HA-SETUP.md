# High Availability Control Plane Setup

## Overview

This cluster uses a 2-node HA control plane with kube-vip for automatic VIP failover.

## Architecture
```
                    ┌─────────────────┐
                    │  VIP: 10.10.0.100│
                    │    (kube-vip)    │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼────────┐          ┌────────▼────────┐
     │   k8s-cp01      │          │  k8s-worker05   │
     │  10.10.0.103    │          │   10.10.0.115   │
     │   (VM/Proxmox)  │          │  (Bare Metal)   │
     │                 │          │                 │
     │ - API Server    │          │ - API Server    │
     │ - etcd          │          │ - etcd          │
     │ - Controller    │          │ - Controller    │
     │ - Scheduler     │          │ - Scheduler     │
     │ - kube-vip      │          │ - kube-vip      │
     └─────────────────┘          │ - GPU (P4)      │
                                  └─────────────────┘
```

## Components

### kube-vip
- Provides floating VIP (10.10.0.100)
- Leader election between control planes
- ARP-based failover
- Manifests: `/etc/kubernetes/manifests/kube-vip.yaml`

### etcd
- 2-member cluster
- Stacked topology (runs on control plane nodes)
- Automatic data replication

## Failover Behavior

| Scenario | Result |
|----------|--------|
| k8s-cp01 down | VIP moves to worker05, cluster accessible |
| k8s-worker05 down | VIP stays on cp01, cluster accessible |
| Both down | Cluster unavailable |

**Note:** With 2 etcd members, losing one means no quorum. For true HA, add a 3rd control plane.

## Key Files

| Node | File | Purpose |
|------|------|---------|
| Both | `/etc/kubernetes/manifests/kube-vip.yaml` | VIP failover |
| Both | `/etc/kubernetes/admin.conf` | Cluster admin kubeconfig |
| Both | `/etc/kubernetes/pki/` | Certificates |

## Useful Commands
```bash
# Check VIP location
ping 10.10.0.100

# Check etcd members
kubectl -n kube-system exec -it etcd-k8s-cp01 -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  member list

# Check kube-vip pods
kubectl get pods -n kube-system | grep kube-vip

# Check control plane components
kubectl get pods -n kube-system | grep -E "apiserver|etcd|controller|scheduler"

# View kube-vip leader
kubectl logs -n kube-system kube-vip-k8s-cp01 | tail -5
```

## Recovery Procedures

### If a control plane goes down:
1. VIP automatically fails over
2. Check cluster is accessible: `kubectl get nodes`
3. Repair the failed node
4. Verify it rejoins: `kubectl get pods -n kube-system | grep kube-vip`

### If etcd loses quorum:
1. Restore from etcd backup: `~/etcd-backups/`
2. See DISASTER-RECOVERY.md for full procedure
