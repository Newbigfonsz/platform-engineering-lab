# Kubernetes Upgrade Plan: 1.28 → 1.31

**Created:** 2026-02-16
**Revised:** 2026-02-26 (Helm compat audit, uptime hardening)
**Current Version:** v1.28.15 (EOL since October 2024)
**Target Version:** v1.31.x (latest supported)
**Path:** 1.28 → 1.29 → 1.30 → 1.31 (kubeadm requires sequential minor versions)

## Urgency

**HIGH** — v1.28 has been end-of-life since October 28, 2024. No security patches are being released. Target 1.31 to land on a currently supported release and enter cert-manager's official support range.

## Pre-Upgrade Checklist

### 1. Deprecated/Removed APIs

| API | Status in 1.29 | Action Required |
|-----|----------------|-----------------|
| `flowcontrol.apiserver.k8s.io/v1beta2` | **Removed** | Not in use (cluster uses v1beta3) — OK |
| `flowcontrol.apiserver.k8s.io/v1beta3` | Available | No action needed until 1.32 (removed in 1.32) |
| `metallb.io/v1beta1 AddressPool` | Deprecated | **Migrate to `IPAddressPool` (metallb.io/v1beta1)** — detected in use |

### 2. Component Compatibility

| Component | Current | Compatible with 1.29-1.31? | Notes |
|-----------|---------|---------------------------|-------|
| etcd | 3.5.15 | Yes | 1.29 bundles 3.5.9; 3.5.15 is newer and compatible |
| containerd (cp01, w01-w04) | 1.7.28 | Yes | |
| containerd (w05) | 2.2.1 | Yes | |
| Calico | in-cluster | Check version | Verify Calico version supports 1.29+ |
| CoreDNS | in-cluster | Auto-upgraded by kubeadm | |
| kube-proxy | 1.28.15 | Auto-upgraded by kubeadm | |

### 3. Helm Releases Compatibility (verified 2026-02-26)

**Key finding: No Helm chart changes needed before upgrading K8s.**

The initial audit flagged cert-manager, Kyverno, and Vault as incompatible. On closer inspection:
- cert-manager v1.19.2 already runs on K8s 1.28 (outside its "supported" 1.31+ range) with no issues. "Supported" is a test boundary, not a hard gate. All 28 certificates are healthy. Downgrading to v1.18.x is far riskier (CRD schema changes, no official downgrade path, potential cert re-issuance storm).
- Kyverno was listed as v1.11.4 but is actually **v1.16.1** (ArgoCD chart 3.6.1). Supports K8s 1.28-1.32+.
- Vault v1.21.2 binary works fine; "tested on 1.31+" is the Helm chart test matrix, not a hard requirement.

| Release | Namespace | Actual Version | K8s 1.29? | Action |
|---------|-----------|---------------|-----------|--------|
| cert-manager | cert-manager | v1.19.2 | **YES** — works on 1.28 now, will work on 1.29-1.31. Officially supported at 1.31 | **None — do NOT downgrade** |
| external-secrets | external-secrets | v1.3.1 | **YES** — supports K8s 1.19+ | None |
| harbor | harbor | v2.14.1 (chart 1.18.1) | **YES** — supports K8s 1.20+ | None |
| kyverno | kyverno | **v1.16.1** (chart 3.6.1) | **YES** — supports K8s 1.28-1.32+ | None |
| loki-stack | monitoring | v2.9.3 (chart 2.10.3) | **YES** — supports K8s 1.10+ | None (chart deprecated but functional) |
| longhorn | longhorn-system | v1.10.1 (chart 1.10.1) | **YES** — supports K8s 1.25+ | Advisory: apply hotfix-2 image for unrelated bug fixes |
| vault | vault | v1.21.2 (chart 0.32.0) | **YES** — binary works, chart untested on 1.29 but no issues expected | None — monitor post-upgrade |
| velero | velero | v1.17.1 (chart 11.3.2) | **YES** — supports K8s 1.18+ | None |

### 4. Uptime Risk Assessment (identified 2026-02-26)

**These are the real threats to 99% uptime during the upgrade:**

| Risk | Component | Replicas | failurePolicy | Impact if down |
|------|-----------|----------|---------------|----------------|
| ~~CRITICAL~~ | ingress-nginx-controller | **2** (worker01, worker02) | — | **MITIGATED** |
| ~~CRITICAL~~ | kyverno-admission-controller | **2** (cp01, worker05) | **Fail** | **MITIGATED** |
| ~~HIGH~~ | cert-manager-webhook | **2** (worker04, worker05) | **Fail** | **MITIGATED** |
| **HIGH** | kyverno-cleanup-controller | **1** | **Fail** | Blocks cleanup operations |
| **MEDIUM** | PDBs with maxUnavailable=0 | ArgoCD, Vault, Grafana, Prometheus, etc. | — | `kubectl drain` hangs — see drain map below |
| ~~BLOCKER~~ | SSH access | nsenter pods tested | — | **MITIGATED** |

**Kyverno policies (low risk during upgrade):**
- `disallow-privileged` — **Enforce** (only enforcing policy)
- `disallow-latest-tag` — Audit
- `require-app-label` — Audit
- `require-labels` — Audit
- `require-non-root` — Audit
- `require-resource-limits` — Audit

### 5. Pre-Requisites

- [x] **Phase 0 hardening completed** (2026-02-28)
  - [x] ingress-nginx scaled to 2 replicas (worker01, worker02)
  - [x] kyverno-admission-controller scaled to 2 replicas (cp01, worker05)
  - [x] cert-manager + webhook scaled to 2 replicas (worker04, worker05)
  - [x] All scaled pods verified on different nodes
- [ ] etcd snapshot taken (CronJob runs every 6h, or trigger manually)
- [ ] Velero backup verified
- [ ] All nodes Ready, all pods healthy
- [ ] No firing alerts (except Watchdog)
- [x] MetalLB AddressPool migrated to IPAddressPool — already done, AddressPool is empty
- [x] Node access solved — nsenter pod template tested and working (with resource limits for ResourceQuota)
- [x] v1.29 apt repo configured on ALL 6 nodes (signed-by path standardized to .gpg)
- [x] Drain strategy mapped (see per-node drain map below)

### 6. Per-Node Drain Map (as of 2026-02-28)

**Upgrade order:** cp01 → worker05 → worker02 → worker03 → worker04 → worker01

#### cp01 (control plane — `kubeadm upgrade apply`, NO drain needed)
Control plane upgrade does NOT drain the node. Pods stay running.
- kyverno-admission-controller (2nd replica) — other replica on worker05 covers it
- loki-0 — emptyDir, no PDB, will restart fine
- Longhorn instance-manager — PDB minAvailable=1, but Longhorn manages this
- **Action:** No PDB relaxation needed. Just run `kubeadm upgrade apply`.

#### worker05 (control plane — `kubeadm upgrade node`, NO drain needed)
- kyverno-admission-controller (1st replica) — other replica on cp01 covers it
- cert-manager (2nd replica) — other replica on worker04
- alertmanager — PDB maxUnavailable=0 **→ relax if draining**
- prometheus — PDB maxUnavailable=0 **→ relax if draining**
- Longhorn instance-manager
- **Action:** No drain needed for control plane upgrade. If drain IS needed:
  ```bash
  kubectl -n monitoring patch pdb alertmanager-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n monitoring patch pdb prometheus-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  ```

#### worker02 (first worker to drain)
- argocd-repo-server — PDB maxUnavailable=0 **→ MUST relax**
- ingress-nginx-controller (1 of 2) — PDB maxUnavailable=1, OK
- Longhorn instance-manager
- **Action before drain:**
  ```bash
  kubectl -n argocd patch pdb argocd-repo-server-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl drain k8s-worker02 --ignore-daemonsets --delete-emptydir-data --timeout=120s
  ```
- **After uncordon, restore:**
  ```bash
  kubectl -n argocd patch pdb argocd-repo-server-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  ```

#### worker03
- external-secrets — PDB maxUnavailable=0 **→ MUST relax**
- platform-store postgres — PDB maxUnavailable=0 **→ MUST relax**
- platform-store product-service — PDB maxUnavailable=0 **→ MUST relax**
- taskapp postgres — PDB minAvailable=1 **→ MUST relax (only 1 replica)**
- Longhorn instance-manager
- **Action before drain:**
  ```bash
  kubectl -n external-secrets patch pdb external-secrets-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n platform-store patch pdb postgres-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n platform-store patch pdb product-service-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n taskapp patch pdb postgres-pdb --type merge -p '{"spec":{"minAvailable":0}}'
  kubectl drain k8s-worker03 --ignore-daemonsets --delete-emptydir-data --timeout=120s
  ```
- **After uncordon, restore:**
  ```bash
  kubectl -n external-secrets patch pdb external-secrets-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n platform-store patch pdb postgres-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n platform-store patch pdb product-service-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n taskapp patch pdb postgres-pdb --type merge -p '{"spec":{"minAvailable":1}}'
  ```

#### worker04
- argocd-server — PDB maxUnavailable=0 **→ MUST relax**
- cert-manager (1st replica) — PDB maxUnavailable=0 **→ MUST relax**
- platform-store gateway — PDB maxUnavailable=0 **→ MUST relax**
- vault-1 — PDB maxUnavailable=0 **→ MUST relax**
- Longhorn instance-manager
- **Action before drain:**
  ```bash
  kubectl -n argocd patch pdb argocd-server-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n cert-manager patch pdb cert-manager-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n platform-store patch pdb gateway-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n vault patch pdb vault --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl drain k8s-worker04 --ignore-daemonsets --delete-emptydir-data --timeout=120s
  ```
- **After uncordon, restore:**
  ```bash
  kubectl -n argocd patch pdb argocd-server-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n cert-manager patch pdb cert-manager-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n platform-store patch pdb gateway-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n vault patch pdb vault --type merge -p '{"spec":{"maxUnavailable":0}}'
  ```

#### worker01 (LAST — has etcd member)
- grafana — PDB maxUnavailable=0 **→ MUST relax**
- vault-0 (ACTIVE leader) — PDB maxUnavailable=0 **→ MUST relax**
- ingress-nginx-controller (1 of 2) — PDB maxUnavailable=1, OK
- Longhorn instance-manager
- **Action before drain:**
  ```bash
  kubectl -n monitoring patch pdb grafana-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl -n vault patch pdb vault --type merge -p '{"spec":{"maxUnavailable":1}}'
  kubectl drain k8s-worker01 --ignore-daemonsets --delete-emptydir-data --timeout=120s
  ```
- **After uncordon, restore:**
  ```bash
  kubectl -n monitoring patch pdb grafana-pdb --type merge -p '{"spec":{"maxUnavailable":0}}'
  kubectl -n vault patch pdb vault --type merge -p '{"spec":{"maxUnavailable":0}}'
  ```
- **Note:** worker01 has an etcd member added manually (not kubeadm-managed). After `kubeadm upgrade node`, verify etcd is healthy. May need manual etcd binary update.
- [x] kube-vip manifests backed up to `backups/kube-vip/` (cp01 + worker05)
- [x] Technitium DNS moved off cp01 to Longhorn (no local-storage PV blocking drain)

## Upgrade Procedure

### Phase 0: Harden for Uptime (Days Before Upgrade)

**This phase eliminates single-points-of-failure before any K8s changes.**

```bash
# 1. Scale ingress-nginx to 2 replicas (prevents traffic blackout during drain)
kubectl -n ingress-nginx scale deploy ingress-nginx-controller --replicas=2

# 2. Scale Kyverno admission controller to 2+ replicas
#    (prevents cluster-wide pod operation lockout during drain)
kubectl -n kyverno scale deploy kyverno-admission-controller --replicas=2

# 3. Scale cert-manager webhook to 2 replicas
kubectl -n cert-manager scale deploy cert-manager-webhook --replicas=2
kubectl -n cert-manager scale deploy cert-manager --replicas=2

# 4. Verify all scaled deployments have pods on DIFFERENT nodes
kubectl get pods -n ingress-nginx -o wide
kubectl get pods -n kyverno -o wide
kubectl get pods -n cert-manager -o wide
# If pods land on the same node, add pod anti-affinity or use topologySpreadConstraints

# 5. Solve node access for worker01-04
#    Option A: Deploy SSH keys to all workers via worker05
#    Option B: Prepare privileged nsenter pods with upgrade scripts
#    See "Node Access Strategy" section below

# 6. Review PDBs that will block drain
#    These PDBs have maxUnavailable=0 (drain will hang if pod can't evict):
#    - argocd-repo-server-pdb, argocd-server-pdb
#    - cert-manager-pdb
#    - external-secrets-pdb
#    - ingress-nginx-pdb
#    - kyverno-admission-pdb
#    - alertmanager-pdb, grafana-pdb, loki-pdb, prometheus-pdb
#    - vault
#    Temporarily relax during maintenance window:
kubectl -n argocd patch pdb argocd-server-pdb --type merge -p '{"spec":{"maxUnavailable":1}}'
# ... repeat for other PDBs on the node being drained
# RESTORE after each node upgrade completes

# 7. Verify cluster health
~/health-check.sh
~/cluster-health-check.sh
```

### Phase 1: Prepare (Day Of)

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

# 5. Verify kube-vip static pod survived
ls -la /etc/kubernetes/manifests/

# 6. Verify
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

# 4. Verify kube-vip static pod survived
ls -la /etc/kubernetes/manifests/
```

### Phase 4: Upgrade Worker Nodes (one at a time)

For each worker (worker01 through worker04):

```bash
# From control plane:
# 1. Cordon the node
kubectl cordon k8s-worker0X

# 2. Temporarily relax PDBs on this node if drain hangs
#    Check which PDB-protected pods are on this node first:
kubectl get pods -A -o wide --field-selector spec.nodeName=k8s-worker0X

# 3. Drain the node (PDBs will protect critical pods)
kubectl drain k8s-worker0X --ignore-daemonsets --delete-emptydir-data --timeout=120s

# On the worker node (via nsenter pod or SSH):
# 4. Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.29.15-1.1
sudo apt-mark hold kubeadm

# 5. Upgrade node config
sudo kubeadm upgrade node

# 6. Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.29.15-1.1 kubectl=1.29.15-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# From control plane:
# 7. Uncordon
kubectl uncordon k8s-worker0X

# 8. Verify node is Ready and pods rescheduled
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed

# 9. Restore any relaxed PDBs before proceeding to next node
```

**Worker upgrade order:** worker02 → worker03 → worker04 → worker01

worker01 hosts etcd member — upgrade last. worker05 is 2nd control plane + etcd member — already upgraded in Phase 3.

### Phase 5: Post-1.29 Verification

```bash
# 1. All nodes on 1.29
kubectl get nodes

# 2. All pods healthy
kubectl get pods -A | grep -v Running | grep -v Completed

# 3. etcd healthy
kubectl -n kube-system exec etcd-k8s-cp01 -- etcdctl \
  --endpoints=https://10.10.0.103:2379,https://10.10.0.115:2379,https://10.10.0.104:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint status -w table

# 4. Full health check
~/health-check.sh
~/cluster-health-check.sh

# 5. Test all ingress endpoints
curl -sk https://alphonzojonesjr.com
curl -sk https://grafana.alphonzojonesjr.com
curl -sk https://taskapp.alphonzojonesjr.com
# ... all 8 endpoints from cluster-health-check.sh

# 6. Verify Helm releases still work
helm list -A

# 7. Verify cert-manager renewals work
kubectl get certificates -A -o wide
```

### Phase 6: Continue to 1.30

Repeat Phases 1-5, replacing `1.29` with `1.30` throughout.

```bash
# Update apt repo to 1.30
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
# Then repeat: kubeadm upgrade, kubelet upgrade, node by node
```

### Phase 7: Continue to 1.31

Repeat Phases 1-5, replacing version with `1.31`.

At 1.31, cert-manager v1.19.2 is in its officially supported range.

### Phase 8: Restore and Verify

```bash
# 1. Scale back replicas (if desired, to save resources)
kubectl -n ingress-nginx scale deploy ingress-nginx-controller --replicas=1
kubectl -n kyverno scale deploy kyverno-admission-controller --replicas=1
kubectl -n cert-manager scale deploy cert-manager-webhook --replicas=1
kubectl -n cert-manager scale deploy cert-manager --replicas=1

# 2. Restore all PDBs to original values

# 3. Final full health check
~/health-check.sh
~/cluster-health-check.sh

# 4. Verify all ArgoCD apps synced
kubectl -n argocd get applications
```

## Node Access Strategy

SSH only works to worker05 (`bigfonsz@10.10.0.115`). For worker01-04, use a privileged nsenter pod to run apt commands:

```bash
# Template: run apt upgrade on a worker node
# NOTE: Resource limits required — namespaces have ResourceQuotas
NODE=k8s-worker0X
VERSION=1.29.15-1.1
kubectl run "upgrade-${NODE}" --image=ubuntu:22.04 --restart=Never --overrides='{
  "spec": {
    "nodeName": "'${NODE}'",
    "hostPID": true,
    "containers": [{
      "name": "nsenter",
      "image": "ubuntu:22.04",
      "command": ["nsenter", "--target", "1", "--mount", "--uts", "--ipc", "--net", "--", "/bin/bash", "-c",
        "set -e; apt-mark unhold kubeadm && apt-get install -y kubeadm='${VERSION}' && apt-mark hold kubeadm && kubeadm upgrade node && apt-mark unhold kubelet kubectl && apt-get install -y kubelet='${VERSION}' kubectl='${VERSION}' && apt-mark hold kubelet kubectl && systemctl daemon-reload && systemctl restart kubelet && echo UPGRADE COMPLETE"],
      "securityContext": {"privileged": true},
      "resources": {"requests": {"cpu": "100m", "memory": "256Mi"}, "limits": {"cpu": "1", "memory": "512Mi"}}
    }]
  }
}'
# Monitor: kubectl logs upgrade-${NODE} -f
# Cleanup: kubectl delete pod upgrade-${NODE}
```

**Alternative:** Deploy SSH keys from worker05 to all nodes before starting the upgrade.

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

1. **SSH access limited** — Only worker05 accessible via SSH. Other nodes require privileged nsenter pods. See "Node Access Strategy" above.

2. **Non-standard etcd on worker01** — etcd member added manually (not via kubeadm). `kubeadm upgrade` may not manage it. May need manual etcd binary update on worker01.

3. **kube-vip static pods** — Custom manifests on cp01 and worker05. Verify they survive the upgrade (kubeadm may overwrite `/etc/kubernetes/manifests/`). Back up manifests before each control plane upgrade.

4. **containerd version mismatch** — worker05 runs 2.2.1 while others run 1.7.28. Not a problem but worth noting.

5. **PDBs with maxUnavailable=0** — 12 PDBs will block `kubectl drain`. Must temporarily relax per-node during drain. See Phase 0 and Phase 4.

## Estimated Downtime

- **API server:** ~1-2 minutes per control plane upgrade (VIP failover)
- **External traffic:** Zero if ingress-nginx scaled to 2+ replicas
- **Workloads:** Zero if drained properly with PDB management
- **Total procedure per version:** ~2-3 hours for 6 nodes
- **Total for 1.28 → 1.31:** ~3 sessions (can be spread across days)

## Future Path

After 1.31:
- 1.31 is currently supported — no immediate urgency
- Plan 1.31 → 1.32 before `flowcontrol.apiserver.k8s.io/v1beta3` removal
- At 1.32+, review Kyverno CRD exclusion workaround in argocd-cm (may no longer be needed)
