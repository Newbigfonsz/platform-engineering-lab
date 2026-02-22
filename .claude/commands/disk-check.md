Run a comprehensive disk usage audit across all 6 nodes and PVCs. Report findings with severity levels and actionable recommendations.

## 1. Node Disk Pressure Conditions

```bash
kubectl get nodes -o custom-columns=NODE:.metadata.name,DISK_PRESSURE:.status.conditions[?(@.type=='DiskPressure')].status
```

If any node reports `True`, flag it as CRITICAL immediately.

## 2. Node Root Filesystem Usage

For each node, check root filesystem usage. Use `kubectl debug` for nodes without SSH (all except worker05):

```bash
kubectl debug node/k8s-cp01 --image=busybox -- df -h /host 2>/dev/null
kubectl debug node/k8s-worker01 --image=busybox -- df -h /host 2>/dev/null
kubectl debug node/k8s-worker02 --image=busybox -- df -h /host 2>/dev/null
kubectl debug node/k8s-worker03 --image=busybox -- df -h /host 2>/dev/null
kubectl debug node/k8s-worker04 --image=busybox -- df -h /host 2>/dev/null
```

For worker05 (SSH available): `ssh bigfonsz@10.10.0.115 df -h /`

Pay special attention to **cp01** which has historically been at ~51% (previously ~90%).

Clean up debug pods after:
```bash
kubectl get pods -A --field-selector=status.phase==Succeeded -o name | xargs -r kubectl delete -A
```

## 3. PVC Usage Across All Namespaces

List all PVCs with capacity:
```bash
kubectl get pvc -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.status.capacity.storage,STORAGECLASS:.spec.storageClassName
```

Check actual usage on high-priority PVCs by exec-ing into pods that mount them:
```bash
kubectl exec -n technitium deploy/technitium -- df -h /opt/technitium 2>/dev/null || echo "Cannot check technitium"
kubectl exec -n velero deploy/minio -- df -h /data 2>/dev/null || echo "Cannot check minio"
kubectl exec -n ollama deploy/ollama -- df -h /root/.ollama 2>/dev/null || echo "Cannot check ollama"
```

Known high-usage PVCs to watch:
- **Technitium PVC** (50Gi) — historically at ~90%
- **MinIO/Velero PVC** (50Gi) — etcd snapshots stored here
- **Ollama PVC** (50Gi) — LLM model files

## 4. Longhorn Volume Health

```bash
kubectl get volumes.longhorn.io -n longhorn-system -o custom-columns=NAME:.metadata.name,STATE:.status.state,ROBUSTNESS:.status.robustness,SIZE:.spec.size 2>/dev/null || echo "Longhorn not available"
```

## Report Format

After gathering all data, produce a summary:

```
=== DISK USAGE REPORT ===

--- NODE ROOT FILESYSTEM ---
Node         | Used | Available | Use% | Status
-------------|------|-----------|------|---------
k8s-cp01     | 48G  | 45G       | 51%  | OK
...

--- PVC USAGE ---
Namespace  | PVC Name       | Capacity | Used  | Use% | Status
-----------|----------------|----------|-------|------|---------
technitium | technitium-pvc | 50Gi     | 45Gi  | 90%  | CRITICAL
...
```

Severity thresholds:
- **OK**: < 80%
- **WARNING**: >= 80%
- **CRITICAL**: >= 90%

## Recommendations

For each flagged item, provide specific cleanup steps:

**Node root filesystem**:
- Clean container images: `crictl rmi --prune` (via kubectl debug)
- Remove completed pods: `kubectl delete pods --field-selector=status.phase==Succeeded -A`
- Vacuum journals: `journalctl --vacuum-size=500M` on the node

**Technitium PVC**: Rotate/compress DNS query logs, purge old cache

**MinIO/Velero PVC**: Prune old Velero backups, review etcd snapshot retention (every 6h)

**Ollama PVC**: Remove unused models with `kubectl exec -n ollama deploy/ollama -- ollama rm <model>`

End with overall cluster disk health: **HEALTHY** / **NEEDS ATTENTION** / **CRITICAL**
