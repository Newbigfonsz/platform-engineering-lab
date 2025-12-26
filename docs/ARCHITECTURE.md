# Platform Engineering Lab Architecture

## Infrastructure Layer
┌─────────────────────────────────────────────────────────────────────┐
│                    PROXMOX VE HOST (10.10.0.210)                    │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │ k8s-cp01    │  │ k8s-worker01│  │ k8s-worker02│                 │
│  │ 10.10.0.103 │  │ 10.10.0.104 │  │ 10.10.0.105 │                 │
│  │ Control     │  │ Worker      │  │ Worker      │                 │
│  │ Plane       │  │             │  │ + Technitium│                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
└─────────────────────────────────────────────────────────────────────┘

## Kubernetes Services

| Service | Namespace | URL | Type |
|---------|-----------|-----|------|
| TaskApp | taskapp | https://taskapp.alphonzojonesjr.com | Full-Stack App |
| ArgoCD | argocd | https://argocd.alphonzojonesjr.com | GitOps |
| Grafana | monitoring | https://grafana.alphonzojonesjr.com | Monitoring |
| Loki | monitoring | Internal | Logging |
| Prometheus | monitoring | Internal | Metrics |
| Technitium | technitium | https://dns.alphonzojonesjr.com | DNS |
| Vault | vault | https://vault.alphonzojonesjr.com | Secrets |
| Uptime Kuma | uptime-kuma | https://status.alphonzojonesjr.com | Status Page |
| K8s Dashboard | kubernetes-dashboard | https://k8s.alphonzojonesjr.com | Cluster UI |
| Kyverno | kyverno | Internal | Policy Engine |

## Network Configuration

| Resource | IP/Range |
|----------|----------|
| Subnet | 10.10.0.0/24 |
| Gateway | 10.10.0.1 |
| DNS Server | 10.10.0.221 |
| Ingress LB | 10.10.0.220 |
| MetalLB Pool | 10.10.0.220-250 |

## GitOps Flow
GitHub Repo ──push──> ArgoCD ──sync──> Kubernetes
│                   │
│                   └── Auto-sync enabled
└── apps/, argocd/apps/

## Credentials

All credentials stored securely. Retrieve via:

| Service | Command |
|---------|---------|
| ArgoCD | `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` |
| Grafana | `kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" \| base64 -d` |
| K8s Dashboard | `kubectl -n kubernetes-dashboard create token admin-user` |
| Vault | Stored in password manager |
| Technitium | Stored in password manager |

## Monitoring Stack

- **Prometheus**: Metrics collection
- **Grafana**: Visualization (99.985% availability SLO)
- **Loki**: Log aggregation
- **Promtail**: Log shipping
- **Uptime Kuma**: External monitoring

## Security

- **Kyverno**: Policy enforcement
- **Network Policies**: Pod-to-pod traffic control
- **Pod Security Standards**: Baseline enforcement
- **Vault**: Secrets management with K8s auth
