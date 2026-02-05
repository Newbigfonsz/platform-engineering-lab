# Platform Engineering Lab - Operations Runbook

## 🏗️ Platform Overview

Production-grade Kubernetes homelab demonstrating enterprise patterns.

| Component | Technology | Purpose |
|-----------|------------|---------|
| Orchestration | Kubernetes 1.28 (kubeadm) | Container orchestration |
| GitOps | ArgoCD | Declarative deployments |
| Secrets | HashiCorp Vault + AWS KMS | Secret management + auto-unseal |
| Monitoring | Prometheus + Grafana | Metrics & visualization |
| Logging | Loki + Promtail | Centralized logs |
| Alerting | Alertmanager + Discord | Incident notification |
| Ingress | NGINX + Cert-Manager | TLS termination |
| Tunnel | Cloudflared | Zero-trust access |
| Storage | Longhorn | Distributed block storage |
| Backup | Velero + MinIO + Synology + B2 | 3-2-1 backup strategy |
| DNS | Technitium | Internal DNS |
| Load Balancer | MetalLB | Bare-metal LB |

---

## 🖥️ Cluster Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     Control Plane                            │
│  k8s-cp01 (10.10.0.103) - etcd, api-server, scheduler       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼───────┐     ┌───────▼───────┐     ┌───────▼───────┐
│  k8s-worker01 │     │  k8s-worker02 │     │  k8s-worker03 │
│   (active)    │     │   (active)    │     │   (active)    │
└───────────────┘     └───────────────┘     └───────────────┘
        │                     │
┌───────▼───────┐     ┌───────▼───────┐
│  k8s-worker04 │     │  k8s-worker05 │
│   (active)    │     │  (hardware)   │
└───────────────┘     └───────────────┘
```

---

## 📋 Daily Operations

### Health Check
```bash
~/health-check.sh
```

### Quick Status
```bash
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed
kubectl exec -n vault vault-0 -- vault status | grep Sealed
```

### Check ArgoCD Apps
```bash
kubectl get applications -n argocd
```

---

## 🔐 Vault Operations

### Architecture
- **HA Mode**: 2 replicas with Raft storage
- **Auto-Unseal**: AWS KMS (Key: 63bdb59f-27af-486a-94a1-be6bc3a98976)
- **Region**: us-east-1
- **Cost**: ~$1/month

### Check Vault Status
```bash
kubectl exec -n vault vault-0 -- vault status
kubectl exec -n vault vault-1 -- vault status
```

### Login to Vault
```bash
kubectl exec -it -n vault vault-0 -- vault login
# Enter root token when prompted
```

### Emergency: Manual Unseal (if KMS fails)
```bash
# Get recovery keys from secure storage
kubectl exec -n vault vault-0 -- vault operator unseal <recovery-key-1>
kubectl exec -n vault vault-0 -- vault operator unseal <recovery-key-2>
kubectl exec -n vault vault-0 -- vault operator unseal <recovery-key-3>
```

### Raft Cluster Recovery
If Vault cluster loses quorum:
```bash
# Scale to 0
kubectl scale statefulset vault -n vault --replicas=0

# Create recovery peers.json
kubectl run vault-debug --rm -it --image=alpine --restart=Never -n vault \
  --overrides='{"spec":{"containers":[{"name":"vault-debug","image":"alpine","command":["sh"],"stdin":true,"tty":true,"resources":{"requests":{"cpu":"100m","memory":"128Mi"},"limits":{"cpu":"200m","memory":"256Mi"}},"volumeMounts":[{"name":"data","mountPath":"/vault/data"}]}],"volumes":[{"name":"data","persistentVolumeClaim":{"claimName":"data-vault-0"}}]}}'

# Inside pod:
cat > /vault/data/raft/peers.json << 'PEERS'
[{"id": "vault-0", "address": "vault-0.vault-internal:8201", "non_voter": false}]
PEERS
exit

# Scale back up
kubectl scale statefulset vault -n vault --replicas=1

# Unseal with -migrate if needed
kubectl exec -n vault vault-0 -- vault operator unseal -migrate <key>
```

---

## 💾 Backup & Recovery

### Backup Architecture (3-2-1)
- **3 copies**: Cluster + Synology NAS + Backblaze B2
- **2 media types**: Local storage + Cloud
- **1 offsite**: Backblaze B2

### Check Velero Backups
```bash
kubectl get backups.velero.io -n velero
kubectl get schedules -n velero
```

### Manual Backup
```bash
kubectl create -f - <<BACKUP
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: manual-backup-$(date +%Y%m%d-%H%M)
  namespace: velero
spec:
  includedNamespaces:
  - taskapp
  - vault
  - argocd
  ttl: 168h
BACKUP
```

### Restore from Backup
```bash
# List available backups
kubectl get backups.velero.io -n velero

# Restore to same namespace
kubectl create -f - <<RESTORE
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-$(date +%H%M)
  namespace: velero
spec:
  backupName: <backup-name>
  includedNamespaces:
  - taskapp
RESTORE

# Restore to different namespace (test)
kubectl create -f - <<RESTORE
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-test-$(date +%H%M)
  namespace: velero
spec:
  backupName: <backup-name>
  includedNamespaces:
  - taskapp
  namespaceMapping:
    taskapp: taskapp-test
RESTORE
```

### Database Backup (PostgreSQL)
```bash
# Manual backup
kubectl exec -n taskapp deploy/postgres -- pg_dump -U taskapp taskappdb > ~/taskapp-$(date +%Y%m%d).sql

# Restore
cat ~/taskapp-backup.sql | kubectl exec -i -n taskapp deploy/postgres -- psql -U taskapp taskappdb
```

---

## 📊 Monitoring & Alerting

### Access Dashboards
- **Grafana**: https://grafana.alphonzojonesjr.com
- **ArgoCD**: https://argocd.alphonzojonesjr.com
- **Vault**: https://vault.alphonzojonesjr.com

### Check Firing Alerts
```bash
kubectl get --raw '/api/v1/namespaces/monitoring/services/alertmanager-operated:9093/proxy/api/v2/alerts' | jq -r '.[].labels.alertname' | sort -u
```

### Alert Rules Configured
| Alert | Trigger | Severity |
|-------|---------|----------|
| HPAAtMaxReplicas | At max for 15m | warning |
| HPANearMaxReplicas | >80% for 10m | warning |
| HPAScalingDisabled | Metrics unavailable 5m | warning |
| HPAFrequentScaling | >5 changes in 10m | warning |
| NodeCPUNearCapacity | >75% for 30m | warning |
| NodeMemoryNearCapacity | >75% for 30m | warning |
| PVCNearCapacity | >75% for 15m | warning |
| ClusterCPUOvercommit | >80% requests | warning |
| ClusterMemoryOvercommit | >80% requests | warning |
| NamespaceQuotaNearLimit | >80% quota | warning |

### View Logs (Loki)
```bash
# Via Grafana Explore, or:
kubectl logs -n <namespace> <pod> --tail=100
```

---

## 🔄 Scaling & HPA

### Current HPAs
```bash
kubectl get hpa -A
```

### Manual Scale
```bash
# Scale deployment
kubectl scale deployment <name> -n <namespace> --replicas=3

# Check HPA status
kubectl describe hpa <name> -n <namespace>
```

### Taskapp HPA Settings
| Component | Min | Max | CPU Target | Memory Target |
|-----------|-----|-----|------------|---------------|
| Backend | 2 | 10 | 70% | 80% |
| Frontend | 2 | 8 | 70% | 80% |

---

## 🛡️ Pod Disruption Budgets

### Current PDBs
```bash
kubectl get pdb -A
```

### Taskapp PDBs
| Component | minAvailable |
|-----------|--------------|
| backend | 1 |
| frontend | 1 |
| postgres | 1 |

---

## 🌐 Networking

### Ingress
```bash
kubectl get ingress -A
kubectl get svc -n ingress-nginx
```

### Cloudflare Tunnel
```bash
kubectl get pods -n cloudflared
kubectl logs -n cloudflared -l app=cloudflared --tail=20
```

### Network Policies
```bash
kubectl get networkpolicies -A
```

### DNS Resolution Test
```bash
kubectl run -it --rm dns-test --image=busybox --restart=Never -- nslookup kubernetes.default
```

---

## 🚨 Troubleshooting

### Pod Won't Start
```bash
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### Node Issues
```bash
kubectl describe node <node>
kubectl get pods -A -o wide --field-selector spec.nodeName=<node>
```

### Storage Issues
```bash
kubectl get pvc -A
kubectl get pv
kubectl describe pvc <pvc> -n <namespace>
```

### ArgoCD Sync Issues
```bash
kubectl get application <app> -n argocd -o yaml | grep -A20 "status:"
kubectl patch application <app> -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

### Certificate Issues
```bash
kubectl get certificates -A
kubectl describe certificate <cert> -n <namespace>
kubectl get certificaterequest -A
```

---

## 🔧 Maintenance Tasks

### Drain Node for Maintenance
```bash
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
# ... perform maintenance ...
kubectl uncordon <node>
```

### Update ArgoCD App
```bash
# Edit in git, push, then:
kubectl patch application <app> -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

### Force Delete Stuck Pod
```bash
kubectl delete pod <pod> -n <namespace> --force --grace-period=0
```

### Clean Up Completed Jobs
```bash
kubectl delete jobs -A --field-selector status.successful=1
```

---

## 📞 Emergency Contacts & Resources

### Key Repositories
- **GitOps Repo**: https://github.com/Newbigfonsz/platform-engineering-lab
- **ArgoCD Apps**: `apps/` directory
- **Vault Config**: `apps/vault/`

### Recovery Priority
1. **Vault** - Secrets for all apps
2. **ArgoCD** - Deploys everything else
3. **Ingress** - External access
4. **Monitoring** - Visibility
5. **Applications** - User-facing

### Useful Commands Cheatsheet
```bash
# Quick health
~/health-check.sh

# All pods status
kubectl get pods -A | grep -v Running

# Resource usage
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -20

# Events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Restart deployment
kubectl rollout restart deployment <name> -n <namespace>

# Check secrets
kubectl get secrets -n <namespace>
```

---

## 📈 Platform Metrics

### Monthly Costs
| Service | Cost |
|---------|------|
| AWS KMS | ~$1 |
| Backblaze B2 | ~$5 (estimated) |
| **Total** | **~$6/month** |

### Uptime Target: 99%
- Achieved through: HA Vault, HPAs, PDBs, Probes, Alerts, 3-2-1 Backups

---

*Last Updated: February 2026*
*Maintainer: Alphonzo Jones Jr*
