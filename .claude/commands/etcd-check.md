Run a comprehensive etcd health check on the 3-member cluster (cp01, worker05, worker01).

## Endpoint Health
```bash
kubectl -n kube-system exec etcd-cp01 -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health
```

## Member List
```bash
kubectl -n kube-system exec etcd-cp01 -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list -w table
```

## Endpoint Status (DB size, leader, raft index)
```bash
kubectl -n kube-system exec etcd-cp01 -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status -w table
```

## Check etcd pods
```bash
kubectl -n kube-system get pods -l component=etcd -o wide
```

## Check latest snapshot CronJob
```bash
kubectl -n kube-system get cronjobs -o wide 2>/dev/null; kubectl -n kube-system get jobs --sort-by=.metadata.creationTimestamp | tail -5
```

Provide a summary with:
- Cluster quorum status (all 3 members healthy?)
- Current leader
- DB sizes and whether defrag is needed (flag if >100MB)
- Raft index alignment between members
- Latest backup status
- Known context: cp01/worker01 have slower disks (~270ms p99) vs worker05 (~16ms)
