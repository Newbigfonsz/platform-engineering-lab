# 🚀 Platform Engineering Lab

[![CI/CD Pipeline](https://github.com/Newbigfonsz/platform-engineering-lab/actions/workflows/ci.yaml/badge.svg)](https://github.com/Newbigfonsz/platform-engineering-lab/actions/workflows/ci.yaml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28-blue?logo=kubernetes)](https://kubernetes.io)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)](https://terraform.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange?logo=argo)](https://argoproj.github.io/cd)

A production-grade Platform Engineering demonstration featuring Infrastructure as Code, GitOps, and modern DevOps practices.

## 🏗️ Architecture
## 🌐 Live Services

| Service | URL | Description |
|---------|-----|-------------|
| TaskApp | [taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com) | Full-stack demo app |
| ArgoCD | [argocd.alphonzojonesjr.com](https://argocd.alphonzojonesjr.com) | GitOps dashboard |
| Grafana | [grafana.alphonzojonesjr.com](https://grafana.alphonzojonesjr.com) | Monitoring |
| Demo | [demo.alphonzojonesjr.com](https://demo.alphonzojonesjr.com) | Landing page |
| DNS | [dns.alphonzojonesjr.com](https://dns.alphonzojonesjr.com) | Technitium DNS |
| Vault | [vault.alphonzojonesjr.com](https://vault.alphonzojonesjr.com) | Secrets Management |(https://dns.alphonzojonesjr.com) | Technitium DNS |

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Infrastructure | Proxmox VE, Terraform |
| Orchestration | Kubernetes (kubeadm) |
| Networking | MetalLB, Ingress-nginx, Calico |
| GitOps | ArgoCD |
| Monitoring | Prometheus, Grafana |
| DNS | Technitium (449K+ blocked domains) |
| Ingress | Cloudflare Tunnel |
| Security | Network Policies, Pod Security Standards |

## 📁 Repository Structure
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

## 📊 Key Features

- **Infrastructure as Code**: All infrastructure defined in Terraform
- **GitOps**: ArgoCD automatically syncs cluster state from Git
- **Observability**: Full metrics with Prometheus/Grafana
- **Security**: Network policies, pod security standards
- **DNS Management**: Self-hosted DNS with ad blocking
- **Disaster Recovery**: Documented runbook, automated backups

## 📖 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Disaster Recovery](docs/DISASTER-RECOVERY.md)
- [Demo Script](docs/DEMO-SCRIPT.md)

## 👤 Author

**Alphonzo Jones Jr.**

- GitHub: [@Newbigfonsz](https://github.com/Newbigfonsz)
- Website: [alphonzojonesjr.com](https://alphonzojonesjr.com)

## 📝 License

This project is licensed under the MIT License.
