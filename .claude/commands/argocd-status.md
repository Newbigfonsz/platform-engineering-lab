Check the status of all ArgoCD applications and report any issues.

## All Applications
```bash
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,NAMESPACE:.spec.destination.namespace
```

## Detailed view of any OutOfSync or Degraded apps
```bash
kubectl -n argocd get applications -o json | jq -r '.items[] | select(.status.sync.status != "Synced" or .status.health.status != "Healthy") | "\(.metadata.name): sync=\(.status.sync.status) health=\(.status.health.status)"'
```

## Recent sync operations
```bash
kubectl -n argocd get applications -o json | jq -r '.items[] | "\(.metadata.name): lastSync=\(.status.operationState.finishedAt // "never") phase=\(.status.operationState.phase // "unknown")"' | sort
```

Provide a summary with:
- Total apps and their sync/health breakdown
- Any apps that need attention (OutOfSync, Degraded, Missing)
- Known expected OutOfSync apps (loki: immutable StatefulSet VCT, taskapp: immutable PVC) should be noted but not flagged as problems
- Recommendations for any real issues
