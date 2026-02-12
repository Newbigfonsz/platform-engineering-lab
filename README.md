# 🔥 Platform Engineering Lab

**Production-grade Kubernetes homelab with GPU-accelerated local AI**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28-326CE5?logo=kubernetes)](https://kubernetes.io)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?logo=argo)](https://argoproj.github.io/cd/)
[![NVIDIA](https://img.shields.io/badge/NVIDIA-Tesla_P4-76B900?logo=nvidia)](https://www.nvidia.com/)
[![Ollama](https://img.shields.io/badge/Ollama-Local_LLM-000000)](https://ollama.ai)

---

## 🏗️ Infrastructure Overview

| Component | Details |
|-----------|---------|
| **Cluster** | 6-node Kubernetes (1 control plane + 5 workers) |
| **GPU Node** | HP Z240 + NVIDIA Tesla P4 8GB |
| **Virtualization** | Proxmox VE (3 VMs) |
| **Bare Metal** | 3 worker nodes |
| **Storage** | Longhorn distributed + Synology DS423 NAS |
| **Backup** | 3-2-1 strategy → Proxmox → Synology → Backblaze B2 |
| **Networking** | Cloudflare Tunnel, Technitium DNS |
| **GitOps** | ArgoCD with auto-sync |

---

## 🤖 AI/ML Stack

| Component | URL | Description |
|-----------|-----|-------------|
| **Ollama** | [ollama.alphonzojonesjr.com](https://ollama.alphonzojonesjr.com) | Local LLM inference API |
| **Open WebUI** | [ai.alphonzojonesjr.com](https://ai.alphonzojonesjr.com) | ChatGPT-style interface |
| **Platform Assistant** | [chat.alphonzojonesjr.com](https://chat.alphonzojonesjr.com) | AI chatbot powered by local GPU |

**Models Available:**
- Llama 3.2 (3B) - General purpose
- Mistral 7B - Advanced reasoning
- CodeLlama 7B - Code generation

**Hardware:**
- NVIDIA Tesla P4 8GB GDDR5
- CUDA 12.8 / Driver 570.211.01
- ~100 tokens/sec inference speed

---

## 🌐 Live Services

| Service | URL | Tech Stack |
|---------|-----|------------|
| Portfolio | [alphonzojonesjr.com](https://alphonzojonesjr.com) | FastAPI, Python |
| TaskApp | [taskapp.alphonzojonesjr.com](https://taskapp.alphonzojonesjr.com) | FastAPI, React, PostgreSQL |
| URL Shortener | [short.alphonzojonesjr.com](https://short.alphonzojonesjr.com) | FastAPI, PostgreSQL |
| ArgoCD | [argocd.alphonzojonesjr.com](https://argocd.alphonzojonesjr.com) | GitOps CD |
| Grafana | [grafana.alphonzojonesjr.com](https://grafana.alphonzojonesjr.com) | Monitoring |
| Vault | [vault.alphonzojonesjr.com](https://vault.alphonzojonesjr.com) | Secrets Management |
| Status Page | [status.alphonzojonesjr.com](https://status.alphonzojonesjr.com) | Uptime Kuma |
| Code Server | [code.alphonzojonesjr.com](https://code.alphonzojonesjr.com) | VS Code in Browser |
| Harbor | [registry.alphonzojonesjr.com](https://registry.alphonzojonesjr.com) | Container Registry |
| FileBrowser | [files.alphonzojonesjr.com](https://files.alphonzojonesjr.com) | File Management |
| n8n | [n8n.alphonzojonesjr.com](https://n8n.alphonzojonesjr.com) | Workflow Automation |
| Technitium | [dns.alphonzojonesjr.com](https://dns.alphonzojonesjr.com) | DNS Server |

---

## 📁 Repository Structure
```
platform-engineering-lab/
├── apps/                    # Application manifests
│   ├── ollama/             # GPU LLM server
│   ├── open-webui/         # AI chat interface
│   ├── chatbot/            # Platform assistant
│   ├── taskapp/            # Task management app
│   └── ...
├── argocd/                 # ArgoCD applications
│   └── apps/               # App-of-apps pattern
├── docs/                   # Documentation
│   ├── backup/             # Backup procedures
│   ├── ARCHITECTURE.md
│   ├── RUNBOOK.md
│   └── DISASTER-RECOVERY.md
├── gitops/                 # GitOps configurations
├── manifests/              # Core infrastructure
├── network-policies/       # Security policies
├── scripts/                # Automation scripts
└── terraform/              # IaC definitions
```

---

## 🛡️ Security & Reliability

- **GitOps**: All changes through Git PRs
- **Network Policies**: Default-deny with explicit allows
- **Secrets**: HashiCorp Vault integration
- **TLS**: Cloudflare SSL termination
- **Backup**: Automated 3-2-1 backup strategy
- **Monitoring**: Prometheus + Grafana + Uptime Kuma

---

## 🔧 Tech Stack

**Infrastructure:**
- Kubernetes v1.28 (kubeadm)
- Proxmox VE 8.x
- Ubuntu 24.04 LTS
- Longhorn Storage
- Cloudflare Tunnel

**DevOps/GitOps:**
- ArgoCD
- GitHub Actions
- Terraform
- Ansible

**Observability:**
- Prometheus
- Grafana
- Loki
- Uptime Kuma

**AI/ML:**
- Ollama
- Open WebUI
- NVIDIA Container Toolkit
- CUDA 12.8

---

## 👨‍💻 About

Built by **Alphonzo Jones Jr.** — Platform/DevOps Engineer

**Certifications:**
- AWS Certified Cloud Practitioner (CCP)
- AWS Certified Solutions Architect Associate (SAA)

**Education:**
- AAS Cloud Computing, Northern Virginia Community College

**Links:**
- 🌐 [alphonzojonesjr.com](https://alphonzojonesjr.com)
- 💼 [LinkedIn](https://linkedin.com/in/alphonzojonesjr)
- 🐙 [GitHub](https://github.com/Newbigfonsz)

---

## 🚀 Quick Start
```bash
# Clone the repo
git clone https://github.com/Newbigfonsz/platform-engineering-lab.git

# Deploy an app with ArgoCD
kubectl apply -f argocd/apps/ollama.yaml

# Check GPU status
kubectl describe node k8s-worker05 | grep nvidia
```

---

*Fire Snake Homelab 🐍🔥*
