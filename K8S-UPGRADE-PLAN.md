# Kubernetes Upgrade Plan: 1.28 → 1.29

**Date:** 2026-02-16
**Current Version:** v1.28.15 (EOL since October 2024)
**Target Version:** v1.29.15 (latest 1.29 patch)

## Urgency

**HIGH** — v1.28 has been end-of-life since October 28, 2024. No security patches are being released. Upgrade to 1.29 should be prioritized.

## Pre-Upgrade Checklist

### 1. Deprecated/Removed APIs

| API | Status in 1.29 | Action Required |
|-----|----------------|-----------------|
| `flowcontrol.apiserver.k8s.io/v1beta2` | **Removed** | Not in use (cluster uses v1beta3) — OK |
| `flowcontrol.apiserver.k8s.io/v1beta3` | Available | No action needed for 1.29 (removed in 1.32) |
| `metallb.io/v1beta1 AddressPool` | Deprecated | **Migrate to `IPAddressPool` (metallb.io/v1beta1)** — detected in use |

### 2. Component Compatibility

| Component | Current | Compatible with 1.29? | Notes |
|-----------|---------|----------------------|-------|
| etcd | 3.5.15 | Yes | 1.29 bundles 3.5.9; 3.5.15 is newer and compatible |
| containerd (cp01, w01-w04) | 1.7.28 | Yes | |
| containerd (w05) | 2.2.1 | Yes | |
| Calico | in-cluster | Check version | Verify Calico version supports 1.29 |
| CoreDNS | in-cluster | Auto-upgraded by kubeadm | |
| kube-proxy | 1.28.15 | Auto-upgraded by kubeadm | |

### 3. Helm Releases to Verify

| Release | Namespace | Notes |
|---------|-----------|-------|
| cert-manager v1.19.2 | cert-manager | Check 1.29 compat |
| external-secrets 1.3.1 | external-secrets | Check 1.29 compat |
| harbor 1.18.1 | harbor | Check 1.29 compat |
| kyverno 3.1.4 | kyverno | Check 1.29 compat |
| loki-stack 2.10.3 | monitoring | Check 1.29 compat |
| longhorn 1.10.1 | longhorn-system | Check 1.29 compat |
| vault 0.32.0 | vault | Check 1.29 compat |
| velero 11.3.2 | velero | Check 1.29 compat |

### 4. Pre-Requisites

- [ ] etcd snapshot taken (CronJob runs every 6h, or trigger manually)
- [ ] Velero backup verified
- [ ] All nodes Ready, all pods healthy
- [ ] No firing alerts (except Watchdog)
- [ ] MetalLB AddressPool migrated to IPAddressPool
- [ ] All Helm charts verified for 1.29 compatibility
- [ ] Drain strategy planned (PDBs are in place)

## Upgrade Procedure

### Phase 1: Prepare (Day Before)

```bash
# 1. Take fresh etcd snapshot
kubectl create job --from=cronjob/etcd-snapshot -n kube-system etcd-snapshot-pre-upgrade

# 2. Take Velero backup
velero backup create pre-upgrade-$(date +%Y%m%d) --wait

# 3. Verify cluster health
~/health-check.sh

# 4. Add 1.29 apt repository on ALL nodes
# On each node:
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
```

### Phase 2: Upgrade Control Plane 1 (k8s-cp01)

```bash
# 1. Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.29.15-1.1
sudo apt-mark hold kubeadm

# 2. Verify upgrade plan
sudo kubeadm upgrade plan

# 3. Apply upgrade (control plane components + etcd)
sudo kubeadm upgrade apply v1.29.15

# 4. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.29.15-1.1 kubectl=1.29.15-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# 5. Verify
kubectl get nodes
```

### Phase 3: Upgrade Control Plane 2 (k8s-worker05)

```bash
# SSH to worker05
ssh bigfonsz@10.10.0.115

# 1. Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.29.15-1.1
sudo apt-mark hold kubeadm

# 2. Upgrade node (not 'apply', use 'node' for additional control planes)
sudo kubeadm upgrade node

# 3. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.29.15-1.1 kubectl=1.29.15-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### Phase 4: Upgrade Worker Nodes (one at a time)

For each worker (worker01 through worker04):

```bash
# From control plane:
# 1. Cordon the node
kubectl cordon k8s-worker0X

# 2. Drain the node (PDBs will protect critical pods)
kubectl drain k8s-worker0X --ignore-daemonsets --delete-emptydir-data

# On the worker node (via kubectl debug or SSH):
# 3. Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.29.15-1.1
sudo apt-mark hold kubeadm

# 4. Upgrade node config
sudo kubeadm upgrade node

# 5. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.29.15-1.1 kubectl=1.29.15-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# From control plane:
# 6. Uncordon
kubectl uncordon k8s-worker0X

# 7. Verify node is Ready and pods rescheduled
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed
```

**Worker upgrade order:** worker02 → worker03 → worker04 → worker01

worker01 hosts etcd member — upgrade last. worker04 (GPU node) should be tested carefully.

### Phase 5: Post-Upgrade Verification

```bash
# 1. All nodes on 1.29
kubectl get nodes

# 2. All pods healthy
kubectl get pods -A | grep -v Running | grep -v Completed

# 3. etcd healthy
kubectl exec -n kube-system etcd-k8s-cp01 -- etcdctl endpoint health ...

# 4. Full health check
~/health-check.sh

# 5. Test all ingress endpoints
# Run n8n health check workflow

# 6. Verify Helm releases still work
helm list -A
```

## Rollback Plan

If upgrade fails mid-way:

1. **Control plane rollback:** Restore etcd from snapshot, reinstall 1.28 packages
2. **Worker rollback:** Install 1.28 kubelet packages, restart kubelet
3. **Full rollback:** Restore etcd snapshot, reinstall 1.28 on all nodes

```bash
# Restore etcd from pre-upgrade snapshot
sudo systemctl stop kubelet
sudo etcdctl snapshot restore /path/to/snapshot.db \
  --data-dir=/var/lib/etcd-restored
sudo mv /var/lib/etcd /var/lib/etcd-old
sudo mv /var/lib/etcd-restored /var/lib/etcd
sudo systemctl start kubelet
```

## Known Issues

1. **SSH access limited** — Only worker05 accessible via SSH. Other nodes require `kubectl debug node/` for filesystem access, which complicates upgrades. Consider fixing SSH keys before upgrade.

2. **Non-standard etcd on worker01** — etcd member added manually (not via kubeadm). `kubeadm upgrade` may not manage it. May need manual etcd binary update on worker01.

3. **kube-vip static pods** — Custom manifests on cp01 and worker05. Verify they survive the upgrade (kubeadm may overwrite `/etc/kubernetes/manifests/`).

4. **containerd version mismatch** — worker05 runs 2.2.1 while others run 1.7.28. Not a problem but worth noting.

## Estimated Downtime

- **API server:** ~1-2 minutes during cp01 upgrade (VIP failover to worker05)
- **Workloads:** Zero downtime if drained properly (PDBs in place)
- **Total procedure:** ~2-3 hours for 6 nodes

## Future Path

After 1.29:
- 1.29 → 1.30 (next step, same procedure)
- Plan to reach 1.31+ for `flowcontrol.apiserver.k8s.io/v1` stable API
- Consider migrating to 1.32+ before v1beta3 removal
