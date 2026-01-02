# Disaster Recovery Runbook

## Full Cluster Rebuild

### 1. Rebuild VMs with Terraform
```bash
cd ~/platform-engineering-lab/terraform/proxmox
terraform apply
```

### 2. Bootstrap Kubernetes
```bash
# On control plane
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.0.103

# Setup kubectl
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config

# Install CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Join workers
kubeadm token create --print-join-command
```

### 3. Install Core Services
```bash
# MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
sleep 30

# MetalLB Config
kubectl apply -f - <<METALEOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.10.0.220-10.10.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
METALEOF

# Ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/baremetal/deploy.yaml
kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
```

### 4. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5. Deploy All Apps via GitOps
```bash
kubectl apply -f argocd/app-of-apps.yaml
```

### 6. Deploy Cloudflared
Get tunnel token from Cloudflare Zero Trust dashboard, then update the secret and apply:
```bash
kubectl create namespace cloudflared
kubectl apply -f apps/cloudflared/deployment.yaml
```

## Backup Procedures

### PostgreSQL (TaskApp)
```bash
kubectl exec -n taskapp deploy/postgres -- pg_dump -U taskapp taskappdb > backup.sql
```

### Restore PostgreSQL
```bash
kubectl exec -i -n taskapp deploy/postgres -- psql -U taskapp taskappdb < backup.sql
```

### Technitium Config
```bash
# Backup
ssh ubuntu@10.10.0.105 "sudo tar czf /tmp/technitium-backup.tar.gz /mnt/data/technitium"
scp ubuntu@10.10.0.105:/tmp/technitium-backup.tar.gz .

# Restore
scp technitium-backup.tar.gz ubuntu@10.10.0.105:/tmp/
ssh ubuntu@10.10.0.105 "sudo tar xzf /tmp/technitium-backup.tar.gz -C /"
```
