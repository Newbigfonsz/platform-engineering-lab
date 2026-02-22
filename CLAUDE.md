# Platform Engineering Lab

## Cluster Overview
- **6-node K8s cluster** (v1.28.15) — 2 control planes (cp01, cp02), 4 workers (worker01-05)
- **GPU node**: worker05 (Tesla P4)
- **Domain**: *.alphonzojonesjr.com
- **GitOps**: ArgoCD (24 apps), Argo Rollouts
- **Monitoring**: Prometheus/Grafana, Loki, Tempo, OTel Collector
- **Secrets**: Vault HA + External Secrets Operator
- **Policy**: Kyverno (5 policies)
- **etcd**: 3-member cluster (cp01, worker05, worker01)

## Critical Rules — Read Before Every Change

### ArgoCD
- Apps are NOT managed via app-of-apps — must `kubectl apply -f` new Application manifests
- CRD drift: use `ServerSideApply=true` + `RespectIgnoreDifferences=true` sync options for Helm charts with CRDs
- Kyverno: `skipCrds: true` + global CRD exclusion in argocd-cm (K8s 1.28 incompatible with 1.30+ CRD features)
- argocd-cm has global `resource.exclusions` for CRDs — remove after K8s upgrade
- Sync via kubectl: `kubectl -n argocd patch application <name> --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'`
- Hard refresh: patch annotation `argocd.argoproj.io/refresh: hard`

### Secrets & ExternalSecrets
- ESO uses API version `v1` (NOT `v1beta1`)
- `.gitignore` blocks `*-secret.yaml` — use `!` exceptions or `kubectl apply -f` flag
- Vault namespace needs `allow-apiserver-webhook` (port 8080) and `allow-vault-clients` (port 8200/8201) network policies

### Network Policies
- Default-deny is active on all app namespaces — new apps MUST have allow rules
- Init containers doing pip/npm install need port 80/443 egress allowed
- Always verify egress rules before deploying apps with external dependencies

### Databases
- Postgres PVC: if you change credentials, you MUST delete the PVC (data persists old passwords)
- URL-encoded passwords: asyncpg parses DATABASE_URL as URL, so `=` in passwords must be `%3D`

### etcd
- Defrag one member at a time (cluster maintains quorum)
- cp01/worker01 have slower disk (~270ms p99 commit) vs worker05 (~16ms)
- Snapshots: CronJob every 6h → MinIO `etcd-snapshots` bucket

### Node Access
- SSH only works to worker05: `bigfonsz@10.10.0.115`
- All other nodes: use `kubectl debug node/<node-name>`
- Kubelet static pods: busybox `sed -i` creates `.bak` files that confuse kubelet — remove ALL files, restart kubelet, write fresh manifest

### Post-Reboot
- kube-apiserver crash-loops until etcd stabilizes (170+ restarts is normal)
- Cluster self-heals in ~5min — do NOT intervene

## Development Workflow

### Before making changes
1. Read the relevant manifests/configs first
2. Use Plan mode for anything touching the cluster
3. Check ArgoCD app status before and after changes

### Making changes
1. Edit manifests in `/apps/<app-name>/` or `/manifests/`
2. Verify YAML is valid
3. `git add` specific files (never `git add .`)
4. Commit with descriptive message
5. Push — ArgoCD auto-syncs

### After changes
1. Verify ArgoCD sync status: `kubectl -n argocd get applications`
2. Check pod health: `kubectl get pods -n <namespace>`
3. Check events: `kubectl get events -n <namespace> --sort-by=.lastTimestamp`

## Known Issues
- K8s 1.28 is EOL — upgrade plan at K8S-UPGRADE-PLAN.md
- Loki has no persistent storage (emptyDir) — data lost on restart
- cp01 root filesystem at ~51%
- Technitium PVC at ~90% (50Gi)

## Code Conventions
- Express.js with path-to-regexp v8+: use `/{*path}` not `*` for wildcard routes
- OTel Python SDK: use `BatchSpanProcessor` not `BatchSpanExporter`
- Helm values: always pin chart versions in ArgoCD Application manifests
