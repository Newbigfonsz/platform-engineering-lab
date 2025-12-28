# Platform Engineering Lab - Architecture

## Infrastructure Overview
```
                              ┌─────────────────┐
                              │    INTERNET     │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │   CLOUDFLARE    │
                              │     TUNNEL      │
                              └────────┬────────┘
                                       │
┌──────────────────────────────────────┴───────────────────────────────────────┐
│                          PROXMOX VE (Dell T3600)                             │
│                          IP: 10.10.0.210 | 64GB RAM                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  k8s-cp01   │  │k8s-worker01 │  │k8s-worker02 │  │    Pulse    │          │
│  │ 10.10.0.103 │  │ 10.10.0.104 │  │ 10.10.0.105 │  │ 10.10.0.230 │          │
│  │   16GB      │  │    20GB     │  │    20GB     │  │    2GB      │          │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘          │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Services (14 Total)

| Service | URL | Stack |
|---------|-----|-------|
| Portfolio | alphonzojonesjr.com | Nginx |
| Lab | lab.alphonzojonesjr.com | Nginx + SVG |
| TaskApp | taskapp.alphonzojonesjr.com | React + Node + PostgreSQL |
| URL Shortener | short.alphonzojonesjr.com | Python FastAPI + PostgreSQL |
| AI Chat Bot | chat.alphonzojonesjr.com | Python FastAPI + Claude API |
| ArgoCD | argocd.alphonzojonesjr.com | GitOps |
| Grafana | grafana.alphonzojonesjr.com | Monitoring |
| Vault | vault.alphonzojonesjr.com | Secrets |
| DNS | dns.alphonzojonesjr.com | Technitium |
| Status | status.alphonzojonesjr.com | Uptime Kuma |
| K8s Dashboard | k8s.alphonzojonesjr.com | Kubernetes UI |
| Pulse | pulse.alphonzojonesjr.com | Proxmox Monitor |
| Demo | demo.alphonzojonesjr.com | Demo App |
| Registry | registry.alphonzojonesjr.com | Harbor |

## Tech Stack

- **Infrastructure**: Proxmox VE, Terraform
- **Orchestration**: Kubernetes v1.28
- **GitOps**: ArgoCD (13 apps)
- **Monitoring**: Prometheus, Grafana, Loki, Uptime Kuma
- **Secrets**: HashiCorp Vault (auto-unseal)
- **Storage**: Longhorn
- **Security**: Kyverno (3 policies)
- **DNS**: Technitium (449K+ blocked)
- **Tunnel**: Cloudflare

## Key IPs

| Resource | IP |
|----------|-----|
| Gateway | 10.10.0.1 |
| Proxmox | 10.10.0.210 |
| Control Plane | 10.10.0.103 |
| Worker 01 | 10.10.0.104 |
| Worker 02 | 10.10.0.105 |
| Ingress LB | 10.10.0.220 |
| DNS Server | 10.10.0.221 |
| Pulse | 10.10.0.230 |

## GitOps Flow
```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Code   │────▶│ GitHub  │────▶│ ArgoCD  │────▶│  K8s    │
│  Push   │     │  Repo   │     │  Sync   │     │ Deploy  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

## Security

- **Kyverno Policies**: require-app-label, disallow-privileged, disallow-latest-tag
- **Vault**: Auto-unseal CronJob every 5 minutes
- **Network**: Cloudflare Zero Trust Tunnel
- **DNS Blocking**: 449,000+ malicious domains
