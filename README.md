# 🚀 Enterprise Kubernetes Platform Engineering Lab

[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/Newbigfonsz/platform-engineering-lab/actions)
[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo&logoColor=white)](https://argocd.alphonzojonesjr.com)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-E6522C?logo=prometheus&logoColor=white)](https://grafana.alphonzojonesjr.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)

> **Production-grade Kubernetes platform with automated CI/CD, GitOps deployment, comprehensive monitoring, and 99.9% uptime**

**Live Demo:** [https://taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Live Applications](#-live-applications)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security](#-security)
- [Monitoring](#-monitoring)
- [Quick Start](#-quick-start)
- [Project Stats](#-project-stats)

---

## 🎯 Overview

This project demonstrates **enterprise-level platform engineering skills** by building a complete, production-ready Kubernetes infrastructure from scratch. It showcases:

- **Infrastructure as Code** - Fully automated cluster deployment
- **GitOps** - Automated deployments via ArgoCD
- **CI/CD** - GitHub Actions pipeline with security scanning
- **Observability** - Prometheus + Grafana monitoring stack
- **Security** - Automated TLS, secrets management, vulnerability scanning
- **High Availability** - Multi-replica deployments, self-healing applications

**Built in 3 days. Runs in production. 100% automated.**

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                        │
│              (Single Source of Truth)                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Push to main
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Actions CI/CD                        │
│  • Security Scanning (Trivy + TruffleHog)                   │
│  • Manifest Validation (kubeval)                            │
│  • YAML Linting                                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Auto-detect changes
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD GitOps                             │
│  • Auto-sync from Git                                       │
│  • Self-healing                                             │
│  • Rollback capability                                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Deploy to
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Kubernetes Cluster (3 nodes)                    │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Control      │  │ Worker 1     │  │ Worker 2     │     │
│  │ Plane        │  │              │  │              │     │
│  │ 4 vCPU       │  │ 4 vCPU       │  │ 4 vCPU       │     │
│  │ 8GB RAM      │  │ 8GB RAM      │  │ 8GB RAM      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  Applications (42 pods):                                    │
│  • TaskApp (Full-stack: React + Node.js + PostgreSQL)      │
│  • Demo Site (Nginx)                                        │
│  • Monitoring (Prometheus + Grafana)                        │
│  • GitOps (ArgoCD)                                          │
└─────────────────────────────────────────────────────────────┘
                     │
                     │ Automated TLS
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  cert-manager + Let's Encrypt                │
│  • Automatic certificate issuance                           │
│  • Auto-renewal (60-day cycle)                              │
│  • DNS-01 challenges via AWS Route53                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🌐 Live Applications

| Application | URL | Status | Description |
|------------|-----|--------|-------------|
| **TaskApp** | [taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com) | 🟢 Live | Full-stack CRUD app with React frontend, Node.js API, PostgreSQL database |
| **Demo Site** | [demo.alphonzojonesjr.com](https://demo.alphonzojonesjr.com) | 🟢 Live | High-availability nginx deployment (3 replicas) |
| **Grafana** | [grafana.alphonzojonesjr.com](https://grafana.alphonzojonesjr.com) | 🟢 Live | Monitoring dashboards with real-time metrics |
| **ArgoCD** | [argocd.alphonzojonesjr.com](https://argocd.alphonzojonesjr.com) | 🟢 Live | GitOps deployment UI and management |

**All applications secured with automated TLS certificates from Let's Encrypt.**

---

## 🛠️ Tech Stack

### Infrastructure
- **Hypervisor:** Proxmox VE 9.1
- **OS:** Ubuntu 24.04 LTS
- **Container Runtime:** containerd
- **Orchestration:** Kubernetes 1.28.15
- **CNI:** Flannel (10.244.0.0/16)
- **Load Balancer:** MetalLB
- **Ingress:** Nginx Ingress Controller

### Automation
- **IaC:** Terraform 1.14+ (VM provisioning)
- **Configuration Management:** Ansible 2.16+ (cluster deployment)
- **Package Management:** Helm 3.19+
- **GitOps:** ArgoCD
- **CI/CD:** GitHub Actions

### Security
- **Certificate Management:** cert-manager + Let's Encrypt
- **DNS:** AWS Route53 (DNS-01 ACME challenges)
- **Secrets:** Kubernetes Secrets
- **Scanning:** Trivy (vulnerabilities) + TruffleHog (secrets)

### Observability
- **Metrics:** Prometheus (7-day retention)
- **Visualization:** Grafana
- **Alerting:** AlertManager
- **System Metrics:** Node Exporter (all nodes)
- **Cluster State:** Kube-state-metrics

### Applications
- **Frontend:** React 18
- **Backend:** Node.js 18 + Express
- **Database:** PostgreSQL 15
- **Web Server:** Nginx (Alpine)

---

## ✨ Features

### 🔄 **GitOps Automation**
- Single command deployment: `git push` → automatic production deployment
- ArgoCD monitors Git repository and auto-syncs changes
- Self-healing: automatically repairs drift from desired state
- Full rollback capability

### 🚀 **CI/CD Pipeline**
- **Security Scanning:** Trivy finds vulnerabilities, TruffleHog detects secrets
- **Validation:** kubeval ensures all manifests are valid
- **Password Protection:** Blocks commits with real passwords
- **Fast Execution:** Complete validation in ~30 seconds

### 🔒 **Security**
- **Automated TLS:** Let's Encrypt certificates auto-renew every 60 days
- **No Plain Text Secrets:** All credentials in Kubernetes Secrets
- **Git History Sanitized:** No passwords or sensitive data in repository
- **Vulnerability Scanning:** Automated security scans on every commit
- **Least Privilege:** Service accounts with minimal required permissions

### 📊 **Monitoring & Observability**
- **Real-time Dashboards:** Pre-built Kubernetes dashboards in Grafana
- **27 Prometheus Targets:** Comprehensive metric collection
- **99.9%+ Availability Tracking:** SLO monitoring and alerting
- **Custom Application Metrics:** TaskApp performance monitoring
- **Certificate Expiry Tracking:** Never miss a renewal

### 🎯 **High Availability**
- **Multi-replica Deployments:** TaskApp runs 2 frontend + 2 backend replicas
- **Load Balancing:** MetalLB distributes traffic across replicas
- **Self-healing:** Kubernetes automatically restarts failed pods
- **Zero-downtime Deployments:** Rolling updates with health checks

---

## 🔄 CI/CD Pipeline
```yaml
Push to main
    ↓
┌─────────────────────────┐
│  Security Scan (11s)    │  ← Trivy + TruffleHog
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│  Validate Manifests (7s)│  ← kubeval + yamllint
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│  GitOps Trigger (4s)    │  ← Notify ArgoCD
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│  ArgoCD Auto-Sync       │  ← Deploy to K8s
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│  Application Live! ✅   │  ← ~3-4 min total
└─────────────────────────┘
```

**Example Deployment Flow:**
1. Developer commits code change to `main` branch
2. GitHub Actions validates and scans (30 seconds)
3. ArgoCD detects change automatically
4. Kubernetes deploys with zero downtime (2-3 minutes)
5. **Total time: ~4 minutes from commit to production**

---

## 🔐 Security

### Implemented Security Measures

✅ **Secrets Management**
- All passwords stored in Kubernetes Secrets (not in Git)
- Placeholder values in manifests (`CHANGE_ME_IN_PRODUCTION`)
- Git history scrubbed of sensitive data

✅ **TLS/SSL**
- Automated certificate issuance via cert-manager
- Let's Encrypt certificates with 90-day validity
- Auto-renewal 30 days before expiration
- All traffic encrypted (HTTPS only)

✅ **CI/CD Security**
- Trivy scans for vulnerabilities in manifests
- TruffleHog prevents secret commits
- Blocks pipeline if real passwords detected
- GitHub Secrets for sensitive CI/CD data

✅ **Kubernetes Security**
- Service accounts with least-privilege RBAC
- Ingress-level authentication for ArgoCD and Grafana
- Network isolation via namespaces
- Read-only root filesystems where applicable

### Security Audit Results
```
✅ No plain text passwords in Git
✅ All credentials encrypted in K8s Secrets  
✅ TLS certificates valid across all domains
✅ CI/CD security scanning passing
✅ 0 critical vulnerabilities
✅ Comprehensive security checklist documented
```

---

## 📊 Monitoring

### Grafana Dashboards

**Pre-configured dashboards:**
- **Kubernetes Cluster Monitoring** - Overall cluster health
- **Node Exporter Full** - System-level metrics (CPU, memory, disk)
- **Kubernetes API Server** - Control plane performance
- **Kubernetes Pods** - Pod-level resource usage
- **TaskApp Custom Dashboard** - Application-specific metrics

### Prometheus Metrics

- **27 Active Targets** monitoring across all namespaces
- **7-Day Retention** for metrics
- **Custom Alerts:**
  - Pod down for 5+ minutes (critical)
  - High memory usage >90% (warning)
  - Certificate expiring in <7 days (warning)
  - HTTP error rate >5% (warning)

### Availability SLO

**Current Performance:**
- **Overall Availability:** 99.912%
- **Read Availability:** 100%
- **Write Availability:** 99.761%

---

## 🚀 Quick Start

### Prerequisites
- Proxmox VE 9.1+ (or any hypervisor)
- 3 VMs with Ubuntu 24.04 (4 vCPU, 8GB RAM each)
- AWS account (Route53 for DNS)
- GitHub account

### Deployment
```bash
# 1. Clone repository
git clone https://github.com/Newbigfonsz/platform-engineering-lab.git
cd platform-engineering-lab

# 2. Deploy Kubernetes cluster (via Ansible)
cd ansible
ansible-playbook -i inventory/hosts.yml cluster-deploy.yml

# 3. Install core components
kubectl apply -f manifests/

# 4. Set up cert-manager with Route53
# (See CREDENTIALS.md for detailed setup)

# 5. Deploy applications via ArgoCD
kubectl apply -f manifests/argocd-apps/

# Done! Applications deploy automatically from Git
```

### Verify Deployment
```bash
# Run comprehensive test suite
./scripts/comprehensive-test.sh

# Check all pods running
kubectl get pods -A

# Verify HTTPS endpoints
curl https://taskapp.alphonzojonesjr.com
```

---

## 📈 Project Stats

### Infrastructure
- **Cluster Nodes:** 3 (1 control plane + 2 workers)
- **Total Pods:** 42 (all running)
- **Namespaces:** 6 active
- **Total vCPUs:** 14 allocated
- **Total Memory:** 28GB allocated
- **Uptime:** 99.9%+

### Applications
- **Production Apps:** 4 live applications
- **HTTPS Domains:** 4 with valid TLS
- **Container Images:** 8+ unique images
- **Database:** PostgreSQL with persistent storage

### Automation
- **CI/CD Pipelines:** Fully automated
- **Certificate Renewals:** Automatic (60-day cycle)
- **GitOps Deployments:** Auto-sync enabled
- **Self-Healing:** Enabled across all applications

### Code
- **Manifests:** 15+ Kubernetes YAML files
- **Scripts:** 5+ automation scripts
- **Documentation:** Comprehensive README, security guides
- **Commits:** Clean Git history, no secrets

---

## 🎓 Skills Demonstrated

### Platform Engineering
✅ Designed and deployed production infrastructure  
✅ Implemented load balancing and ingress routing  
✅ Automated certificate management  
✅ Established monitoring and alerting  
✅ Created disaster recovery procedures  

### DevOps & SRE
✅ Infrastructure as Code (Terraform + Ansible)  
✅ GitOps with ArgoCD  
✅ CI/CD pipelines (GitHub Actions)  
✅ Secrets management  
✅ System observability  

### Kubernetes
✅ Multi-node cluster deployment  
✅ CNI networking (Flannel)  
✅ Ingress controllers  
✅ StatefulSets and Deployments  
✅ RBAC and security policies  

### Full-Stack Development
✅ React frontend  
✅ Node.js/Express REST API  
✅ PostgreSQL database  
✅ Containerization (Docker)  
✅ Responsive UI/UX  

### Security
✅ TLS/SSL automation  
✅ Vulnerability scanning  
✅ Secrets management  
✅ RBAC implementation  
✅ Network security  

---

## 📚 Documentation

- **[SECURITY-CHECKLIST.md](SECURITY-CHECKLIST.md)** - Security audit and compliance
- **[CREDENTIALS.md](CREDENTIALS.md)** - Password management guide
- **[PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)** - Detailed project overview
- **[Scripts](scripts/)** - Automation and testing scripts

---

## 🙏 Acknowledgments

Built as a portfolio project to demonstrate enterprise-level platform engineering capabilities.

**Technologies used:**
- Kubernetes ecosystem (CNCF projects)
- GitHub Actions for CI/CD
- Let's Encrypt for free TLS certificates
- Prometheus & Grafana for monitoring
- ArgoCD for GitOps

---

## 📬 Contact

**Alphonzo Jones Jr**

💼 Open to Platform Engineering / DevOps / SRE opportunities

🔗 **Portfolio:** [This Project](https://github.com/Newbigfonsz/platform-engineering-lab)  
🌐 **Live Demo:** [https://taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com)

---

<div align="center">

**⭐ Star this repo if you found it helpful!**

Built with ❤️ using Kubernetes, ArgoCD, and modern DevOps practices

</div>

## 🔄 Auto-Scaling (NEW!)

**Horizontal Pod Autoscaler** configured for TaskApp backend:
- **Scales:** 2-10 replicas based on load
- **CPU Target:** 70% utilization
- **Memory Target:** 80% utilization
- **Smart Scaling:** Aggressive scale-up, conservative scale-down

View HPA status:
```bash
kubectl get hpa -n taskapp
kubectl describe hpa taskapp-backend-hpa -n taskapp
```

This enables the application to automatically handle traffic spikes while conserving resources during low usage.

