# Platform Engineering Lab

## Cluster Overview
- **6-node K8s cluster** (v1.29.15) — 2 control planes (cp01, cp02), 4 workers (worker01-05)
- **GPU node**: none (Tesla P4 removed from worker05 — defective)
- **Domain**: *.alphonzojonesjr.com
- **GitOps**: ArgoCD (24 apps — 22 Synced, 2 known OutOfSync), Argo Rollouts
- **Monitoring**: Prometheus/Grafana, Loki, Tempo, OTel Collector
- **Secrets**: Vault HA + External Secrets Operator
- **Policy**: Kyverno (5 policies)
- **etcd**: 3-member cluster (cp01, worker05, worker01)

## Critical Rules — Read Before Every Change

### ArgoCD
- Apps are NOT managed via app-of-apps — must `kubectl apply -f` new Application manifests
- CRD drift: use `ServerSideApply=true` + `RespectIgnoreDifferences=true` sync options for Helm charts with CRDs
- Kyverno: `skipCrds: true` + global CRD exclusion in argocd-cm (K8s 1.29 incompatible with 1.30+ CRD features)
- argocd-cm has global `resource.exclusions` for CRDs — remove after K8s 1.30+ upgrade
- Sync via kubectl: `kubectl -n argocd patch application <name> --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'`
- Hard refresh: patch annotation `argocd.argoproj.io/refresh: hard`

### Secrets & ExternalSecrets
- ESO uses API version `v1` (NOT `v1beta1`)
- `.gitignore` blocks `*-secret.yaml` — use `!` exceptions or `kubectl apply -f` flag
- Vault namespace needs `allow-apiserver-webhook` (port 8080) and `allow-vault-clients` (port 8200/8201) network policies
- Vault uses dynamic credentials (rotating username/password) — CronJobs and batch jobs MUST use vault-agent injection, NOT the `postgres-secret` ExternalSecret
- When adding vault-agent to a CronJob: add the same annotations as the app's Deployment (agent-inject, role, template), then source `/vault/secrets/db-creds` in the command

### Network Policies
- Default-deny is active on all app namespaces — new apps MUST have allow rules
- Init containers doing pip/npm install need port 80/443 egress allowed
- Always verify egress rules before deploying apps with external dependencies

### Databases
- Postgres PVC: if you change credentials, you MUST delete the PVC (data persists old passwords)
- URL-encoded passwords: asyncpg parses DATABASE_URL as URL, so `=` in passwords must be `%3D`

### etcd
- Defrag one member at a time (cluster maintains quorum) — defrag when DB >100MB
- cp01/worker01 have slower disk (~270ms p99 commit) vs worker05 (~16ms)
- Snapshots: CronJob every 6h → MinIO `etcd-snapshots` bucket
- After defrag: DB typically goes from ~130MB → ~28MB (78% reduction)

### Node Access
- SSH only works to worker05: `bigfonsz@10.10.0.115`
- All other nodes: use `kubectl debug node/<node-name>`
- Kubelet static pods: busybox `sed -i` creates `.bak` files that confuse kubelet — remove ALL files, restart kubelet, write fresh manifest

### Helm Charts
- Tempo chart (grafana/tempo 1.7.2): resources go under `tempo.resources:`, NOT top-level `resources:`
- Tempo `memBallastSizeMbs` defaults to 1024 — must be less than memory limit or OOMKill
- Always check the chart's values.yaml for the correct key path before setting resources

### Node Disk Maintenance
- worker01/worker02 have small 31Gi root disks — need periodic cleanup
- Cleanup: prune images (`crictl rmi --prune`), vacuum journals (`journalctl --vacuum-size=200M`), clean apt cache
- Use privileged pod with `nsenter` for node-level cleanup (kubectl debug doesn't return output reliably)
- `kubectl debug node/` output is unreliable — use a hostPath pod with nsenter instead

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
4. Run `/pre-deploy` before pushing to validate manifests

### Slash Commands Available
- `/cluster-health` — full cluster overview (nodes, pods, ArgoCD, etcd, PVCs)
- `/argocd-status` — all 24 apps sync/health with known-issue filtering
- `/etcd-check` — 3-member quorum, DB size, backup status
- `/pod-debug <ns> <pod>` — deep-dive a pod (logs, events, resources, netpol)
- `/netpol-check <ns>` — network policy analysis for a namespace
- `/pre-deploy` — validate manifests before push (GO/NO-GO)
- `/disk-check` — node + PVC disk audit with severity levels
- `/vault-status` — Vault HA, ESO, ExternalSecrets, network policies

## Known Issues
- K8s 1.29 — upgrade plan at K8S-UPGRADE-PLAN.md
- Loki has no persistent storage (emptyDir) — data lost on restart; ArgoCD OutOfSync (immutable StatefulSet VCT)
- Taskapp ArgoCD OutOfSync — immutable PVC storageClass field, harmless
- worker01/worker02 have 31Gi root disks (cleaned to ~65% on 2026-02-22, monitor regularly)
- Technitium PVC improved to ~64% (was ~90%, log cleanup working)
- **Tesla P4 GPU removed from worker05** (2026-02-22) — card was defective (Xid 79 + PCIe RxErr, report at docs/GPU-TEST-REPORT.md). containerd switched to runc default runtime, GPU label removed. Ollama runs CPU-only on worker03/04. NVIDIA packages still installed on worker05 (cleanup optional)

## Resolved Issues (2026-02-22)
- Tempo OOMKill: resources were at wrong Helm path + 1024MB ballast exceeded 512Mi limit → fixed
- Taskapp backup CronJob: missing resource limits + wrong credentials (used ExternalSecret instead of Vault dynamic creds) → fixed with vault-agent injection
- Ollama OutOfSync: `kubectl rollout restart` added annotation not in git → synced
- etcd DB 129MB → defragged to 28MB
- Tesla P4 GPU removal prep: containerd default runtime → runc, GPU label removed, Ollama pinned to worker03/04 CPU-only

## Code Conventions
- Express.js with path-to-regexp v8+: use `/{*path}` not `*` for wildcard routes
- OTel Python SDK: use `BatchSpanProcessor` not `BatchSpanExporter`
- Helm values: always pin chart versions in ArgoCD Application manifests
