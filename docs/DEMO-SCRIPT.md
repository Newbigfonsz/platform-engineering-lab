# Platform Engineering Lab - Demo Script

## Introduction (2 min)
"I built a complete Platform Engineering Lab to demonstrate modern DevOps practices. Let me walk you through the architecture and key components."

## Architecture Overview (3 min)
## Demo Flow

### 1. Infrastructure as Code (Terraform) - 3 min
```bash
cd ~/platform-engineering-lab/terraform/proxmox
cat k8s-cluster.tf
terraform state list
terraform plan  # Show no changes = infrastructure matches code
```

**Talking Points:**
- "VMs are defined in code, version controlled"
- "Can rebuild entire infrastructure with one command"
- "State tracked in Terraform"

### 2. GitOps with ArgoCD - 5 min

**Show ArgoCD Dashboard:**
- Open https://argocd.alphonzojonesjr.com
- Login: admin / (get password from secret)
- Show all applications synced
```bash
kubectl get application -n argocd
```

**Demonstrate GitOps:**
```bash
# Make a change in Git
cd ~/platform-engineering-lab
# Edit apps/demo/deployment.yaml - change replicas from 3 to 4
sed -i 's/replicas: 3/replicas: 4/' apps/demo/deployment.yaml
git add -A && git commit -m "Scale demo to 4 replicas" && git push

# Watch ArgoCD auto-sync (or click Sync in UI)
kubectl get pods -n demo -w
```

**Talking Points:**
- "All deployments are in Git - single source of truth"
- "ArgoCD automatically syncs cluster state to Git"
- "No manual kubectl apply in production"

### 3. Full-Stack Application (TaskApp) - 3 min

**Show TaskApp:**
- Open https://taskapp.alphonzojonesjr.com
- Add a task, complete a task, delete a task

**Show Architecture:**
```bash
kubectl get pods -n taskapp
kubectl get svc -n taskapp
```

**Talking Points:**
- "React frontend, Node.js backend, PostgreSQL database"
- "All containerized and orchestrated by Kubernetes"
- "Horizontal Pod Autoscaler for scaling"

### 4. Monitoring & Observability (Grafana) - 3 min

**Show Grafana:**
- Open https://grafana.alphonzojonesjr.com
- Show Kubernetes dashboard
- Show node metrics, pod metrics
```bash
kubectl top nodes
kubectl top pods -A | head -20
```

**Talking Points:**
- "Prometheus collects metrics from all pods"
- "Grafana provides visualization"
- "Can set up alerts for anomalies"

### 5. DNS & Ad Blocking (Technitium) - 2 min

**Show Technitium:**
- Open https://dns.alphonzojonesjr.com
- Show dashboard with blocked queries
- Show local DNS zones
```bash
nslookup proxmox.home.lab 10.10.0.221
nslookup doubleclick.net 10.10.0.221  # Should be blocked
```

**Talking Points:**
- "Self-hosted DNS with ad blocking"
- "449K+ domains blocked"
- "Local DNS for homelab resources"

### 6. Security - 2 min
```bash
kubectl get networkpolicies -n taskapp
kubectl describe namespace taskapp | grep -A5 Labels
```

**Talking Points:**
- "Network policies restrict pod-to-pod traffic"
- "Pod Security Standards enforced"
- "Zero-trust networking model"

### 7. Disaster Recovery - 2 min
```bash
# Show backup
ls -la ~/backups/
cat ~/platform-engineering-lab/docs/DISASTER-RECOVERY.md
```

**Talking Points:**
- "Automated backups of databases and configs"
- "Full DR runbook documented"
- "Can rebuild entire platform from scratch"

## Q&A Preparation

**Common Questions:**

Q: "Why Kubernetes instead of simpler solutions?"
A: "Kubernetes provides declarative infrastructure, self-healing, and scalability. It's industry standard for container orchestration."

Q: "How do you handle secrets?"
A: "Secrets are stored in Kubernetes secrets, referenced via environment variables. Sensitive values never committed to Git."

Q: "What happens if a node fails?"
A: "Kubernetes automatically reschedules pods to healthy nodes. With 3 nodes, we maintain availability during single node failures."

Q: "How long to rebuild from scratch?"
A: "About 30 minutes. Terraform provisions VMs, kubeadm bootstraps cluster, ArgoCD deploys all applications."

## Commands Cheat Sheet
```bash
# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Check all pods
kubectl get pods -A

# Check services
kubectl get svc -A

# Check ingresses
kubectl get ingress -A

# Terraform state
cd ~/platform-engineering-lab/terraform/proxmox && terraform state list

# Run backup
~/platform-engineering-lab/scripts/backup.sh

# Test all sites
for site in taskapp argocd demo grafana dns; do
  curl -s -o /dev/null -w "$site: %{http_code}\n" https://$site.alphonzojonesjr.com
done
```
