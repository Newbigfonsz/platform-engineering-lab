# 🚀 Platform Engineering Lab

[![Status](https://img.shields.io/badge/Status-All%20Systems%20Operational-brightgreen)](https://status.alphonzojonesjr.com/status/status)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28-blue?logo=kubernetes)](https://kubernetes.io)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)](https://terraform.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange?logo=argo)](https://argoproj.github.io/cd)

A production-grade Platform Engineering demonstration featuring Infrastructure as Code, GitOps, and modern DevOps practices.

## 🌐 Live Services

| Service | URL | Description |
|---------|-----|-------------|
| 📊 Status Page | [status.alphonzojonesjr.com](https://status.alphonzojonesjr.com/status/status) | Uptime Monitoring |
| 🚀 Lab | [lab.alphonzojonesjr.com](https://lab.alphonzojonesjr.com) | Landing Page |
| 📝 TaskApp | [taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com) | Full-Stack Demo App |
| 🔄 ArgoCD | [argocd.alphonzojonesjr.com](https://argocd.alphonzojonesjr.com) | GitOps Dashboard |
| 📈 Grafana | [grafana.alphonzojonesjr.com](https://grafana.alphonzojonesjr.com) | Monitoring & Logs |
| 🛡️ DNS | [dns.alphonzojonesjr.com](https://dns.alphonzojonesjr.com) | Technitium DNS |
| 🔐 Vault | [vault.alphonzojonesjr.com](https://vault.alphonzojonesjr.com) | Secrets Management |
| ☸️ K8s Dashboard | [k8s.alphonzojonesjr.com](https://k8s.alphonzojonesjr.com) | Cluster Management |
| 🌐 Demo | [demo.alphonzojonesjr.com](https://demo.alphonzojonesjr.com) | Demo Site |

## 🏗️ Architecture
┌─────────────────────────────────────────────────────────────────────┐
│                         INTERNET                                     │
│                            │                                         │
│                   Cloudflare Tunnel                                  │
│                            │                                         │
├─────────────────────────────────────────────────────────────────────┤
│                      KUBERNETES CLUSTER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │ k8s-cp01    │  │ k8s-worker01│  │ k8s-worker02│                 │
│  │ Control     │  │ Apps        │  │ Apps + DNS  │                 │
│  │ Plane       │  │             │  │             │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
├─────────────────────────────────────────────────────────────────────┤
│                       PROXMOX HOST                                   │
│                  Managed by Terraform                                │
└─────────────────────────────────────────────────────────────────────┘

## 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| **Infrastructure** | Proxmox VE, Terraform |
| **Orchestration** | Kubernetes (kubeadm) |
| **Networking** | MetalLB, Ingress-nginx, Cloudflare Tunnel |
| **GitOps** | ArgoCD |
| **Monitoring** | Prometheus, Grafana, Loki, Uptime Kuma |
| **Secrets** | HashiCorp Vault |
| **DNS** | Technitium (449K+ blocked domains) |
| **Policy** | Kyverno |
| **Backups** | Automated PostgreSQL CronJob |

## 📁 Repository Structure
platform-engineering-lab/
├── terraform/
│   └── proxmox/              # VM infrastructure
├── apps/
│   ├── taskapp/              # Full-stack application
│   ├── demo/                 # Demo site
│   ├── cloudflared/          # Tunnel connector
│   ├── technitium/           # DNS server
│   ├── nginx-demo/           # Lab landing page
│   ├── uptime-kuma/          # Status page
│   ├── vault/                # Secrets management
│   └── kubernetes-dashboard/ # K8s UI
├── argocd/
│   ├── apps/                 # ArgoCD applications
│   └── app-of-apps.yaml      # Root application
├── manifests/
│   └── security/             # Security policies
├── scripts/                  # Automation scripts
├── docs/                     # Documentation
└── .github/workflows/        # CI/CD pipelines

## 📊 Platform Stats

- **9 Public Services**
- **62+ Running Pods**
- **8 Uptime Monitors**
- **99.985% Availability**
- **449K+ DNS Blocked Domains**

## 📖 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Disaster Recovery](docs/DISASTER-RECOVERY.md)
- [Demo Script](docs/DEMO-SCRIPT.md)

## 🚀 Quick Start

### Prerequisites
- Proxmox VE host
- Cloudflare account
- GitHub account

### Deploy Infrastructure
```bash
cd terraform/proxmox
terraform init
terraform apply
```

### Bootstrap Kubernetes
See [docs/DISASTER-RECOVERY.md](docs/DISASTER-RECOVERY.md)

### Deploy Applications
```bash
kubectl apply -f argocd/app-of-apps.yaml
```

## 👤 Author

**Alphonzo Jones Jr.**

- GitHub: [@Newbigfonsz](https://github.com/Newbigfonsz)
- Website: [alphonzojonesjr.com](https://alphonzojonesjr.com)

## 📝 License

This project is licensed under the MIT License.
