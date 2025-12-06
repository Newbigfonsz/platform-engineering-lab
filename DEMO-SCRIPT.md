# 🎬 Platform Engineering Lab - Live Demo Script

**Duration:** 15-20 minutes  
**Audience:** Technical recruiters, hiring managers, engineering teams

---

## 🎯 Demo Objectives

By the end of this demo, the audience will see:
1. ✅ Live production applications with HTTPS
2. ✅ Complete CI/CD pipeline in action
3. ✅ GitOps automated deployment
4. ✅ Real-time monitoring and observability
5. ✅ Enterprise-grade security practices

---

## 📋 Pre-Demo Checklist
```bash
# Run this before your demo to ensure everything is ready
cd ~/platform-lab

echo "🔍 Pre-Demo Health Check"
echo "========================"
echo ""

# 1. Cluster health
echo "✅ Cluster Status:"
kubectl get nodes
echo ""

# 2. All applications running
echo "✅ Application Pods:"
kubectl get pods -n demo --no-headers | wc -l | xargs echo "  Demo:"
kubectl get pods -n taskapp --no-headers | wc -l | xargs echo "  TaskApp:"
kubectl get pods -n monitoring --no-headers | wc -l | xargs echo "  Monitoring:"
kubectl get pods -n argocd --no-headers | wc -l | xargs echo "  ArgoCD:"
echo ""

# 3. HTTPS endpoints
echo "✅ HTTPS Endpoints:"
for url in https://demo.alphonzojonesjr.com https://taskapp.alphonzojonesjr.com https://grafana.alphonzojonesjr.com https://argocd.alphonzojonesjr.com; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "  $url - $STATUS"
done
echo ""

# 4. TLS certificates
echo "✅ TLS Certificates:"
kubectl get certificate -A | grep -E "NAME|True"
echo ""

echo "🎬 Ready to demo!"
```

---

## 🎤 Demo Script

### **Part 1: Introduction (2 minutes)**

**What to say:**

> "Hi everyone! Today I'm going to walk you through a production-grade Kubernetes platform I built from scratch. This project demonstrates enterprise-level platform engineering skills including infrastructure automation, CI/CD, GitOps, monitoring, and security."

**What to show:**
- Open GitHub repository: https://github.com/Newbigfonsz/platform-engineering-lab
- Scroll through README to show architecture diagram
- Highlight the tech stack badges at the top

**Key talking points:**
- Built in 3 days
- 100% automated deployment
- Production-ready with 99.9% uptime
- Full GitOps workflow

---

### **Part 2: Live Applications (3 minutes)**

**What to say:**

> "Let me show you the live applications running on this platform. Everything is secured with automated TLS certificates from Let's Encrypt."

**Demo steps:**

1. **TaskApp - Full-Stack Application**
   - Open: https://taskapp.alphonzojonesjr.com
   - Point out: "CI/CD Deployed! ✅" badge in subtitle
   - Add a task: "Demo for [Company Name]"
   - Mark it complete
   - Show the statistics updating in real-time

**What to say:**
> "This is a full-stack CRUD application with React frontend, Node.js Express API, and PostgreSQL database. Notice the 'CI/CD Deployed' badge - that was automatically added through our GitOps pipeline, which I'll show you in a moment."

2. **Demo Site**
   - Open: https://demo.alphonzojonesjr.com
   - Show the simple nginx deployment

**What to say:**
> "This demo site runs with 3 replicas for high availability, load balanced via MetalLB."

3. **Show HTTPS certificates**
   - Click the padlock icon in browser
   - Show valid Let's Encrypt certificate

**What to say:**
> "All certificates are automatically issued and renewed by cert-manager using DNS-01 challenges through AWS Route53. Zero manual certificate management."

---

### **Part 3: Kubernetes Infrastructure (3 minutes)**

**What to say:**

> "Let me show you the underlying Kubernetes infrastructure. I'll switch to my terminal."

**Terminal commands:**
```bash
# Show cluster nodes
kubectl get nodes

# Show all running pods
kubectl get pods -A

# Show specific applications
echo "Demo Site (3 replicas):"
kubectl get pods -n demo

echo ""
echo "TaskApp (Full-stack with database):"
kubectl get pods -n taskapp

echo ""
echo "Show LoadBalancer services:"
kubectl get svc -A | grep LoadBalancer
```

**What to say while running commands:**
> "As you can see, we have a 3-node cluster with 42 pods running across 6 namespaces. TaskApp runs 2 frontend replicas, 2 backend API replicas, and a PostgreSQL database - all orchestrated by Kubernetes with automatic failover and self-healing."

---

### **Part 4: CI/CD Pipeline (4 minutes)**

**What to say:**

> "Now let me demonstrate the complete CI/CD pipeline. I'm going to make a code change and you'll see it automatically deploy to production."

**Demo steps:**

1. **Show GitHub Actions**
   - Open: https://github.com/Newbigfonsz/platform-engineering-lab/actions
   - Show the latest successful workflow run
   - Click into it to show the stages: Security Scan → Validate → GitOps → Status

**What to say:**
> "Every commit triggers our CI/CD pipeline. It runs security scans with Trivy and TruffleHog, validates all Kubernetes manifests, and notifies ArgoCD to deploy."

2. **Make a live change**

**Terminal:**
```bash
cd ~/platform-lab

# Make a visible change
sed -i 's/CI\/CD Deployed! ✅/CI\/CD Demo LIVE! 🎬/g' manifests/frontend.yaml

# Commit and push
git add manifests/frontend.yaml
git commit -m "demo: Update frontend badge for live demonstration"
git push origin main

echo ""
echo "✅ Change pushed! Watch GitHub Actions..."
```

3. **Show the pipeline running**
   - Refresh GitHub Actions page
   - Show the new workflow run starting
   - Click into it to show real-time logs

**What to say:**
> "The pipeline is now running. It takes about 30 seconds to validate and scan for security issues."

4. **Show ArgoCD detecting the change**
   - Open: https://argocd.alphonzojonesjr.com
   - Login with admin credentials
   - Click on 'taskapp' application
   - Show it syncing

**What to say:**
> "ArgoCD detected the change in Git and is now automatically deploying it to Kubernetes. This is GitOps in action - Git is the single source of truth."

5. **Wait for deployment (~2-3 minutes)**
   - While waiting, continue with monitoring section
   - Come back to refresh TaskApp to show the new badge

---

### **Part 5: Monitoring & Observability (4 minutes)**

**What to say:**

> "While that deploys, let me show you the monitoring stack. We're using Prometheus for metrics collection and Grafana for visualization."

**Demo steps:**

1. **Show Grafana**
   - Open: https://grafana.alphonzojonesjr.com
   - Login (credentials in notes)
   - Navigate to Dashboards → Browse

**What to say:**
> "We have pre-built dashboards for cluster monitoring, node metrics, and custom application metrics."

2. **Show Kubernetes Cluster Monitoring dashboard**
   - Click on "Kubernetes Cluster Monitoring"
   - Show the 99.9%+ availability metric
   - Point out CPU and memory usage graphs
   - Show HTTP request rates

**What to say:**
> "Here you can see our cluster is maintaining 99.9% availability. We're tracking 27 Prometheus targets across all namespaces with custom alerts for pod failures, high memory usage, and certificate expiration."

3. **Show Node Exporter dashboard**
   - Navigate to "Node Exporter Full"
   - Show system-level metrics for all 3 nodes

**What to say:**
> "Each node is instrumented with node_exporter, giving us detailed system metrics - CPU, memory, disk, network - everything we need for capacity planning and troubleshooting."

4. **Terminal - Show Prometheus targets**
```bash
# Show all monitoring targets
kubectl exec -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -c prometheus -- \
  wget -qO- http://localhost:9090/api/v1/targets 2>/dev/null | jq -r '.data.activeTargets | length'
```

**What to say:**
> "Prometheus is actively monitoring 27 targets across our entire infrastructure."

---

### **Part 6: Security (3 minutes)**

**What to say:**

> "Security is built into every layer of this platform. Let me show you some key security features."

**Demo steps:**

1. **Show automated TLS**
```bash
# Show certificates
kubectl get certificate -A
```

**What to say:**
> "All TLS certificates are automatically issued by cert-manager using Let's Encrypt. They auto-renew 30 days before expiration - zero manual intervention."

2. **Show secrets management**
```bash
# Show that no passwords in Git
echo "Checking Git for passwords..."
git log --all -p | grep -i "password" | grep -v "secretName\|secret:" | head -5 || echo "✅ No passwords in Git!"

# Show secrets in Kubernetes
echo ""
echo "Passwords stored securely in Kubernetes:"
kubectl get secrets -n taskapp | grep postgres
kubectl get secrets -n argocd | grep initial-admin
```

**What to say:**
> "No passwords are stored in Git - they're all in Kubernetes Secrets. Our CI/CD pipeline blocks any commits containing real passwords."

3. **Show GitHub Actions security scan**
   - Go back to GitHub Actions
   - Show a completed workflow
   - Click on "Security Scan" job
   - Show Trivy and TruffleHog results

**What to say:**
> "Every commit is scanned for vulnerabilities and exposed secrets. If anything is found, the pipeline fails before deployment."

---

### **Part 7: GitOps Verification (2 minutes)**

**What to say:**

> "Let's go back and see if our change has deployed."

**Demo steps:**

1. **Check ArgoCD**
   - Refresh ArgoCD UI
   - Show taskapp is "Synced" and "Healthy"

2. **Refresh TaskApp**
   - Open: https://taskapp.alphonzojonesjr.com
   - Show the updated badge: "CI/CD Demo LIVE! 🎬"

**What to say:**
> "And there it is! In less than 5 minutes from code commit to production deployment. This entire flow is automated - I just pushed to Git and ArgoCD handled everything else. This is the power of GitOps."

**Terminal:**
```bash
# Show the deployment history
kubectl rollout history deployment taskapp-frontend -n taskapp

# Show the new pods
kubectl get pods -n taskapp -l app=taskapp-frontend
```

---

### **Part 8: Architecture & Code Walkthrough (2 minutes)**

**What to say:**

> "Let me quickly show you the code structure and infrastructure-as-code approach."

**Demo steps:**

1. **Show repository structure**
```bash
cd ~/platform-lab
tree -L 2 -I 'node_modules|.git'
```

2. **Show a Kubernetes manifest**
```bash
cat manifests/frontend.yaml | head -30
```

**What to say:**
> "All infrastructure is defined as code. These Kubernetes manifests are version controlled, and ArgoCD ensures what's in Git matches what's running in production."

3. **Show the CI/CD workflow**
```bash
cat .github/workflows/cicd-taskapp.yaml | head -50
```

**What to say:**
> "The entire CI/CD pipeline is defined as code in GitHub Actions. It's repeatable, auditable, and version controlled."

---

### **Part 9: Closing & Key Takeaways (2 minutes)**

**What to say:**

> "Let me summarize what we've seen today."

**Show this summary:**
```bash
cat << 'DEMO_END'
╔════════════════════════════════════════════════════════╗
║            DEMO SUMMARY - KEY ACHIEVEMENTS             ║
╚════════════════════════════════════════════════════════╝

✅ Infrastructure
   • 3-node Kubernetes cluster (42 pods)
   • Multi-AZ high availability architecture
   • Automated with Terraform + Ansible

✅ Applications
   • Full-stack TaskApp (React + Node.js + PostgreSQL)
   • Load balanced with MetalLB
   • Zero-downtime deployments

✅ CI/CD & GitOps
   • Automated GitHub Actions pipeline (30s)
   • ArgoCD GitOps deployment (3-4 min)
   • Git as single source of truth

✅ Security
   • Automated TLS certificate management
   • No secrets in Git (all in K8s Secrets)
   • Vulnerability scanning on every commit
   • 99.9% uptime SLO

✅ Monitoring
   • Prometheus metrics (27 targets)
   • Grafana dashboards
   • Real-time alerting

🎯 From commit to production: 4 minutes
🎯 Everything automated: 100%
🎯 Manual interventions required: 0

DEMO_END
```

**Final talking points:**

> "This platform demonstrates enterprise-level skills in:"
> - Platform engineering and infrastructure automation
> - Modern DevOps practices with GitOps
> - Production-grade security and monitoring
> - Full-stack application development
> - Kubernetes orchestration and management
>
> "Everything you've seen is running live, fully automated, and documented in the GitHub repository. The entire platform can be deployed with a single command."

**Show contact info:**
```bash
echo ""
echo "📬 Contact & Links:"
echo "   GitHub: https://github.com/Newbigfonsz/platform-engineering-lab"
echo "   Live Demo: https://taskapp.alphonzojonesjr.com"
echo "   Resume: [Your resume link]"
echo ""
echo "Questions?"
```

---

## 🎯 Common Questions & Answers

### Q: "How long did this take to build?"
**A:** "The initial infrastructure took about 8 hours. Adding applications, monitoring, and CI/CD took another 12 hours. Total project time was about 3 days of focused work."

### Q: "Can you scale this?"
**A:** "Absolutely. I can add more worker nodes via Terraform, and Kubernetes will automatically distribute pods. The applications are already configured for horizontal scaling."

### Q: "What about disaster recovery?"
**A:** "Git is our source of truth, so I can recreate the entire platform from scratch in about 30 minutes using the Ansible playbooks. For data, we'd want to add Velero for backup/restore."

### Q: "What's the cloud cost?"
**A:** "This runs on-premises on Proxmox, so there's no cloud compute cost. The only cost is AWS Route53 for DNS (~$1/month)."

### Q: "How do you handle secrets rotation?"
**A:** "I have a documented security checklist with procedures for rotating all credentials. Certificates auto-rotate via cert-manager."

### Q: "What about production readiness?"
**A:** "For full production, I'd add: network policies, resource quotas, pod security policies, external secrets management (Vault), and distributed storage (Longhorn). The foundation is enterprise-ready."

---

## 🔧 Backup Demo Commands

If something goes wrong during the demo, use these:
```bash
# Force ArgoCD sync
kubectl patch app taskapp -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'

# Restart a deployment
kubectl rollout restart deployment taskapp-frontend -n taskapp

# Check logs
kubectl logs -n taskapp -l app=taskapp-frontend --tail=50

# Force certificate renewal
kubectl delete certificate --all -A
kubectl apply -f manifests/

# Quick cluster health check
kubectl get nodes
kubectl get pods -A | grep -v Running
```

---

## 📸 Screenshots to Prepare

Take these screenshots before your demo as backup:

1. ✅ All pods running (`kubectl get pods -A`)
2. ✅ GitHub Actions successful workflow
3. ✅ ArgoCD synced application
4. ✅ Grafana dashboard showing 99.9% uptime
5. ✅ TaskApp running with tasks
6. ✅ Valid TLS certificates in browser

---

## 🎬 Post-Demo Follow-Up

After the demo, send:
```
Subject: Platform Engineering Lab - Demo Follow-Up

Hi [Name],

Thank you for attending my platform engineering demo today! Here are the links we discussed:

🔗 GitHub Repository: https://github.com/Newbigfonsz/platform-engineering-lab
🌐 Live Application: https://taskapp.alphonzojonesjr.com
📊 Monitoring: https://grafana.alphonzojonesjr.com

Key highlights:
- 3-node Kubernetes cluster with 42 pods
- Automated CI/CD with GitHub Actions
- GitOps deployment with ArgoCD
- 99.9% uptime with comprehensive monitoring
- Complete security hardening

The repository includes full documentation, architecture diagrams, and deployment guides.

I'm excited about the [Position] role and would love to discuss how I can bring these skills to [Company].

Best regards,
Alphonzo Jones Jr
```

---

## 🎯 Demo Tips

✅ **DO:**
- Practice the demo 2-3 times beforehand
- Have all browser tabs open and ready
- Run the pre-demo checklist
- Speak confidently about technical decisions
- Show genuine enthusiasm for the technology

❌ **DON'T:**
- Apologize for anything that's working
- Spend too long on any single section
- Read from the script word-for-word
- Get flustered if something breaks (use backup commands)
- Downplay your achievement

---

**🎬 YOU'VE GOT THIS! This platform is genuinely impressive!**

Good luck with your demo!
