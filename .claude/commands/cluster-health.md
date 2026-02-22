Run a comprehensive cluster health check. Execute ALL of the following checks in parallel where possible, then summarize findings:

## Node Health
```bash
kubectl get nodes -o wide
```

## Pod Issues (non-Running pods across all namespaces)
```bash
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
```

## Resource Usage
```bash
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -20
```

## ArgoCD Application Status
```bash
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

## Recent Events (warnings only)
```bash
kubectl get events -A --field-selector=type=Warning --sort-by=.lastTimestamp | tail -20
```

## Disk Usage on cp01
```bash
kubectl debug node/cp01 --image=busybox -- df -h / 2>/dev/null || echo "Use SSH to check cp01 disk"
```

## PVC Usage
```bash
kubectl get pvc -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.status.capacity.storage
```

## etcd Health
```bash
kubectl -n kube-system exec etcd-cp01 -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health
```

After running all checks, provide a summary with:
- Overall cluster health status (Healthy / Degraded / Critical)
- Any pods not running or in error states
- Any ArgoCD apps out of sync
- Resource pressure warnings
- Actionable items if any issues found
