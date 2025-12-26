# Platform Engineering Lab - Operations Runbook

## Quick Reference

### Access URLs
| Service | URL | Credentials |
|---------|-----|-------------|
| Status Page | https://status.alphonzojonesjr.com/status/status | - |
| ArgoCD | https://argocd.alphonzojonesjr.com | admin / (see below) |
| Grafana | https://grafana.alphonzojonesjr.com | admin / (see below) |
| Vault | https://vault.alphonzojonesjr.com | root token |
| K8s Dashboard | https://k8s.alphonzojonesjr.com | token (see below) |
| Technitium | https://dns.alphonzojonesjr.com | admin / (password manager) |

### Get Credentials
```bash
# ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Grafana admin password
kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d && echo

# K8s Dashboard token
kubectl -n kubernetes-dashboard create token admin-user
```

## Common Operations

### Check Platform Health
```bash
# All services
for site in lab taskapp argocd grafana dns vault demo status k8s; do
  curl -s -o /dev/null -w "$site: %{http_code}\n" https://$site.alphonzojonesjr.com
done

# All pods
kubectl get pods -A | grep -v Running

# ArgoCD apps
kubectl get application -n argocd
```

### Restart a Service
```bash
# Restart deployment
kubectl rollout restart deployment <name> -n <namespace>

# Examples
kubectl rollout restart deployment taskapp-backend -n taskapp
kubectl rollout restart deployment monitoring-grafana -n monitoring
```

### View Logs
```bash
# Pod logs
kubectl logs -n <namespace> <pod-name> --tail=100

# Deployment logs
kubectl logs -n <namespace> deploy/<deployment-name> --tail=100

# Loki (via Grafana)
# Go to Grafana > Explore > Loki > {namespace="taskapp"}
```

### Database Operations
```bash
# Backup PostgreSQL
kubectl exec -n taskapp deploy/postgres -- pg_dump -U taskapp taskappdb > backup.sql

# Restore PostgreSQL
kubectl exec -i -n taskapp deploy/postgres -- psql -U taskapp taskappdb < backup.sql

# Connect to database
kubectl exec -it -n taskapp deploy/postgres -- psql -U taskapp taskappdb
```

### DNS Operations
```bash
# Test DNS resolution
nslookup google.com 10.10.0.221

# Test local DNS
nslookup proxmox.home.lab 10.10.0.221

# Check blocked queries
# Go to https://dns.alphonzojonesjr.com > Dashboard
```

### Vault Operations
```bash
# Check Vault status
kubectl exec -n vault vault-0 -- vault status

# Login to Vault CLI
kubectl exec -it -n vault vault-0 -- /bin/sh
vault login
```

### ArgoCD Operations
```bash
# Sync all apps
kubectl get application -n argocd -o name | xargs -I {} kubectl patch {} -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'

# Force refresh
kubectl patch application <app-name> -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

## Troubleshooting

### Pod Not Starting
```bash
# Check events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace> --previous
```

### Service Not Accessible
```bash
# Check ingress
kubectl get ingress -A

# Check service
kubectl get svc -n <namespace>

# Test internal connectivity
kubectl run test --rm -it --image=busybox -- wget -qO- http://<service>.<namespace>.svc.cluster.local
```

### Cloudflare Tunnel Issues
```bash
# Check tunnel pods
kubectl get pods -n cloudflared

# Check logs
kubectl logs -n cloudflared -l app=cloudflared --tail=50

# Restart tunnel
kubectl rollout restart deployment cloudflared -n cloudflared
```

## Backup & Recovery

### Full Backup
```bash
~/platform-engineering-lab/scripts/backup.sh
```

### Disaster Recovery

See [DISASTER-RECOVERY.md](DISASTER-RECOVERY.md)
