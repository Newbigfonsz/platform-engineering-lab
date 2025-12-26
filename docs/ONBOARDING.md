# Platform Engineering Lab - Onboarding Guide

Welcome to the Platform Engineering Lab! This guide will help you get started.

## Overview

This is a production-grade Kubernetes platform featuring:
- **9 public services** with 100% uptime monitoring
- **GitOps** workflow with ArgoCD
- **Monitoring** with Prometheus, Grafana, and Loki
- **Secrets management** with HashiCorp Vault
- **DNS & ad-blocking** with Technitium
- **Policy enforcement** with Kyverno

## Getting Access

### 1. SSH Access
```bash
ssh ubuntu@10.10.0.103  # Control plane
ssh ubuntu@10.10.0.104  # Worker 1
ssh ubuntu@10.10.0.105  # Worker 2
```

### 2. Kubectl Access
```bash
# On k8s-cp01, kubectl is already configured
kubectl get nodes
```

### 3. Web UIs

| Service | URL | How to Login |
|---------|-----|--------------|
| ArgoCD | https://argocd.alphonzojonesjr.com | admin + password from secret |
| Grafana | https://grafana.alphonzojonesjr.com | admin + password from secret |
| Vault | https://vault.alphonzojonesjr.com | Root token |
| K8s Dashboard | https://k8s.alphonzojonesjr.com | Service account token |

See [RUNBOOK.md](RUNBOOK.md) for credential commands.

## Architecture
Internet → Cloudflare Tunnel → Ingress-nginx → Services
↓
┌──────────────┐
│  Kubernetes  │
│   Cluster    │
│              │
│ ┌──────────┐ │
│ │ ArgoCD   │ │ ← Syncs from GitHub
│ └──────────┘ │
└──────────────┘

## Making Changes

### The GitOps Way (Recommended)

1. Clone the repo:
```bash
   git clone https://github.com/Newbigfonsz/platform-engineering-lab.git
```

2. Make changes to manifests in `apps/` or `argocd/apps/`

3. Commit and push:
```bash
   git add -A
   git commit -m "Your change description"
   git push
```

4. ArgoCD will automatically sync the changes

### Direct kubectl (Emergency Only)
```bash
kubectl apply -f <manifest.yaml>
```

## Key Directories
platform-engineering-lab/
├── apps/           # Application manifests
├── argocd/apps/    # ArgoCD application definitions
├── terraform/      # Infrastructure as Code
├── docs/           # Documentation
└── scripts/        # Automation scripts

## Monitoring

### Check Service Health

- **Status Page**: https://status.alphonzojonesjr.com/status/status
- **Grafana**: https://grafana.alphonzojonesjr.com

### View Logs

1. Go to Grafana > Explore
2. Select "Loki" as data source
3. Query: `{namespace="taskapp"}`

### View Metrics

1. Go to Grafana > Dashboards
2. Select "Kubernetes / API server" or other dashboards

## Common Tasks

### Deploy a New App

1. Create manifests in `apps/your-app/`
2. Create ArgoCD app in `argocd/apps/your-app.yaml`
3. Add Cloudflare tunnel route if needed
4. Push to Git

### Update an Existing App

1. Edit manifests in `apps/<app-name>/`
2. Push to Git
3. ArgoCD syncs automatically

### Check ArgoCD Sync Status
```bash
kubectl get application -n argocd
```

## Getting Help

- **Runbook**: [RUNBOOK.md](RUNBOOK.md)
- **Disaster Recovery**: [DISASTER-RECOVERY.md](DISASTER-RECOVERY.md)
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
