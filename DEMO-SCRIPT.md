# 🎬 Platform Engineering Lab - Demo Script

**Presenter:** Alphonzo Jones Jr.  
**Duration:** 5-10 minutes  
**Platform:** Production Kubernetes with Full GitOps Automation

---

## 🎯 Opening (30 seconds)

*"Hi, I'm Alphonzo Jones Jr. I built a production-grade Kubernetes platform from scratch to demonstrate enterprise DevOps practices. Let me show you what I created."*

**Quick Stats to Mention:**
- 46 pods across 3-node cluster
- 4 production applications
- Complete CI/CD pipeline (4-minute deployments)
- 99.9%+ uptime
- 100% HTTPS with automated TLS

---

## 📋 Demo Flow

### 1. Live Applications (2 minutes)

**Show each application in browser:**

#### Demo Site
🔗 https://demo.alphonzojonesjr.com

*"This is a high-availability nginx deployment with 3 replicas, load-balanced, and secured with automated TLS certificates from Let's Encrypt."*

**Key Points:**
- ✅ Valid HTTPS (show green lock)
- Load balanced across worker nodes
- Automated certificate renewal

---

#### TaskApp - Full-Stack Application
🔗 https://taskapp.alphonzojonesjr.com

*"This is a complete full-stack application with React frontend, Node.js backend, and PostgreSQL database. Let me show you the CRUD operations."*

**Live Demo Actions:**
1. **Create a task:** "Platform Demo in Progress!"
2. **Show it appears** in real-time
3. **Mark it complete** (toggle checkbox)
4. **Delete it**

**Architecture to Mention:**
- React frontend (2 replicas)
- Node.js REST API (2 replicas with HPA 2-10)
- PostgreSQL with persistent storage
- All containerized in Kubernetes

---

#### Grafana Monitoring
🔗 https://grafana.alphonzojonesjr.com

*"I implemented comprehensive monitoring with Prometheus and Grafana to track cluster health and application performance."*

**Show:**
- Kubernetes cluster dashboards
- Pod metrics
- Node resource usage
- 99.9%+ uptime tracking

**Login:** admin / (have password ready)

---

### 2. GitOps with ArgoCD (2 minutes)

🔗 https://argocd.alphonzojonesjr.com (accept cert warning)

*"Everything is deployed through GitOps using ArgoCD. Let me show you how changes automatically sync from Git to production."*

**Show in ArgoCD:**
1. **Application Status:** Healthy & Synced
2. **Visual Topology:** Show the deployment graph
3. **Sync History:** Recent deployments
4. **Source Repository:** GitHub integration

**Key Point:**
*"Every change committed to Git automatically deploys to production in about 3 minutes. No manual kubectl commands needed."*

---

### 3. Infrastructure Overview (2 minutes)

**Open Terminal - Show Commands:**
```bash
# Show cluster health
kubectl get nodes
# Output: 3 nodes (1 control plane, 2 workers) - all Ready

# Show all running pods
kubectl get pods -A | grep Running | wc -l
# Output: 46 pods running

# Show applications
kubectl get pods -n taskapp
# Output: 5 pods (frontend, backend, postgres)

# Show certificates
kubectl get certificates -A
# Output: 3 valid certificates (demo, taskapp, grafana)

# Show HPA (auto-scaling)
kubectl get hpa -n taskapp
# Output: Configured for 2-10 replicas based on CPU/memory
```

**Talk Track:**
*"I built this on bare metal hardware - a 3-node cluster using Dell workstations. Everything is infrastructure-as-code using Terraform and Ansible."*

---

### 4. CI/CD Pipeline (1-2 minutes)

**Open GitHub Repository:**
🔗 https://github.com/Newbigfonsz/platform-engineering-lab

**Show:**
1. **GitHub Actions tab** - Show passing CI/CD runs
2. **Recent commits** - Show automated deployments
3. **manifests/ directory** - Infrastructure as code

**Explain Workflow:**
*"When I push code to GitHub:*
1. *GitHub Actions runs security scanning (Trivy for vulnerabilities, TruffleHog for secrets)*
2. *Validates Kubernetes manifests*
3. *ArgoCD detects the change and syncs to production*
4. *Total time: About 4 minutes from commit to live"*

---

### 5. Architecture & Technologies (1 minute)

**Technologies Used:**
- **Container Orchestration:** Kubernetes 1.28
- **GitOps:** ArgoCD
- **CI/CD:** GitHub Actions
- **Monitoring:** Prometheus + Grafana
- **TLS Automation:** cert-manager + Let's Encrypt
- **Load Balancing:** MetalLB
- **Ingress:** Nginx Ingress Controller
- **Networking:** Flannel CNI
- **Auto-scaling:** Horizontal Pod Autoscaler
- **IaC:** Terraform + Ansible

---

## 💡 Key Talking Points

### What Makes This Impressive:

1. **Production-Grade Setup**
   - Not just a tutorial - actually deployed and running
   - 99.9%+ uptime over multiple weeks
   - Real TLS certificates, real load balancing

2. **Complete Automation**
   - Zero-downtime deployments
   - Automated certificate renewal
   - Auto-scaling based on load
   - Self-healing (pods restart automatically)

3. **Modern DevOps Practices**
   - GitOps (single source of truth)
   - Infrastructure as Code
   - Security scanning in pipeline
   - Comprehensive monitoring

4. **Hands-On Problem Solving**
   - Recovered from CNI networking issues
   - Debugged PostgreSQL authentication
   - Implemented secure secrets management
   - Documented lessons learned

---

## 🎤 Common Interview Questions & Answers

### "Why Kubernetes?"
*"I wanted to learn container orchestration at scale. Kubernetes is the industry standard and understanding it opens doors to cloud platforms like AWS EKS, Azure AKS, and Google GKE."*

### "Why GitOps?"
*"GitOps provides a single source of truth and makes rollbacks trivial. If something breaks, I can revert a Git commit and ArgoCD automatically restores the working state. It also provides a complete audit trail."*

### "What challenges did you face?"
*"The biggest challenge was CNI networking issues after a cluster restart. I had to debug Flannel pod failures, learn about iptables rules, and implement proper recovery procedures. I documented everything in my recovery notes."*

### "How do you handle secrets?"
*"I use Kubernetes Secrets with strict RBAC policies. Secrets are never committed to Git - only placeholders. ArgoCD is configured to ignore sensitive fields. For production, I'd recommend external secret management like Vault or AWS Secrets Manager."*

### "What would you do differently in production?"
*"I'd implement:*
- *External secrets management (HashiCorp Vault)*
- *Multi-cluster setup for high availability*
- *Cloud provider integration (EKS/AKS/GKE)*
- *More comprehensive backup strategy*
- *Cost optimization with cluster autoscaling*
- *Enhanced security with Pod Security Standards"*

### "How do you ensure security?"
*"I implemented:*
- *Automated vulnerability scanning in CI/CD*
- *Secret scanning to prevent credential leaks*
- *TLS everywhere (no plain HTTP)*
- *RBAC for access control*
- *Network policies (would implement more in production)*
- *Regular security audits documented in my checklist"*

---

## 📊 Metrics to Highlight

- **Deployment Speed:** 4 minutes from commit to production
- **Uptime:** 99.9%+ over 3+ weeks
- **Scale:** 46 pods, 3 nodes, 4 applications
- **Automation:** 100% GitOps, zero manual deployments
- **Security:** TLS everywhere, automated scanning, no exposed secrets

---

## 🎯 Closing (30 seconds)

*"This project taught me enterprise DevOps practices from the ground up. I can confidently deploy, monitor, and troubleshoot containerized applications at scale. I'm excited to bring these skills to a production environment and continue learning."*

**Final Action:**
Show all 3 apps open in browser tabs - everything working simultaneously.

---

## 📝 Quick Reference Links

- **Demo Site:** https://demo.alphonzojonesjr.com
- **TaskApp:** https://taskapp.alphonzojonesjr.com
- **Grafana:** https://grafana.alphonzojonesjr.com
- **ArgoCD:** https://argocd.alphonzojonesjr.com
- **GitHub:** https://github.com/Newbigfonsz/platform-engineering-lab

---

## 🔐 Credentials (Keep Private)

**ArgoCD:**
- Username: `admin`
- Password: Run `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d`

**Grafana:**
- Username: `admin`
- Password: Run `kubectl get secret prometheus-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d`

---

## ✅ Pre-Demo Checklist

Run this before every demo:
```bash
cd ~/platform-lab
./scripts/complete-health-check.sh
```

Ensure:
- [ ] All 46 pods running
- [ ] All 3 public apps accessible
- [ ] ArgoCD showing "Healthy & Synced"
- [ ] Have credentials ready

---

**Good luck! You built something genuinely impressive!** 🚀
