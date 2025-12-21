# Disaster Recovery Procedures

## Kubernetes Cluster Recovery

### If Control Plane Fails:
1. SSH to k8s-cp01: `ssh ubuntu@10.10.0.103`
2. Restore etcd: `sudo ETCDCTL_API=3 etcdctl snapshot restore /var/backups/etcd/etcd-backup-XXXXXX.db`
3. Restart kubelet: `sudo systemctl restart kubelet`

### If Worker Node Fails:
1. Drain node: `kubectl drain k8s-worker01 --ignore-daemonsets --delete-emptydir-data`
2. Delete node: `kubectl delete node k8s-worker01`
3. Recreate VM from Proxmox template
4. Re-run Ansible: `ansible-playbook -i inventory/hosts.yml playbooks/install-k8s.yml --limit k8s-worker01`

### If All Nodes Fail:
1. Restore VMs from Proxmox backups
2. Restore kubeconfig from backups
3. Re-run full Ansible playbook

## VM Snapshots (Proxmox)

Take snapshots before major changes:
```bash
ssh root@10.10.0.210 "qm snapshot 103 pre-upgrade-$(date +%Y%m%d)"
```

## Testing Recovery:
Test your backups regularly - a backup you haven't tested is not a backup!
