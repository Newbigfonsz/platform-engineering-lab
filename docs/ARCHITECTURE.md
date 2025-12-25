# Platform Engineering Lab Architecture

## Infrastructure Layer (Terraform)
## Kubernetes Services

| Service | Namespace | URL |
|---------|-----------|-----|
| TaskApp | taskapp | https://taskapp.alphonzojonesjr.com |
| ArgoCD | argocd | https://argocd.alphonzojonesjr.com |
| Grafana | monitoring | https://grafana.alphonzojonesjr.com |
| Demo | demo | https://demo.alphonzojonesjr.com |
| Technitium | technitium | https://dns.alphonzojonesjr.com |

## Network

| Resource | IP |
|----------|-----|
| Ingress LB | 10.10.0.220 |
| DNS Server | 10.10.0.221 |
| Subnet | 10.10.0.0/24 |

## GitOps Flow
## Credentials

All credentials stored securely. Retrieve via:

| Service | Command |
|---------|---------|
| ArgoCD | `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` |
| Grafana | `kubectl -n monitoring get secret prometheus-grafana -o jsonpath="{.data.admin-password}" \| base64 -d` |
| Technitium | Stored in password manager |
| Proxmox | Stored in password manager |
| VMs | Stored in password manager |
