# 🎯 Platform Engineering Lab - Interview Demo Script

## 30-Second Elevator Pitch

> "I built a production-grade Kubernetes platform with 20+ services, GPU-accelerated local AI, GitOps automation, and a 3-2-1 backup strategy — all running on hybrid infrastructure with bare metal and VMs."

---

## 🚀 5-Minute Demo Flow

### 1. Show the AI (WOW Factor) - 1 min
- Open: https://ai.alphonzojonesjr.com
- Ask: "What services are running on this platform?"
- **Key point:** "This is running on MY Tesla P4 GPU, not OpenAI"

### 2. Show GitOps - 1 min
- Open: https://argocd.alphonzojonesjr.com
- Show all synced apps
- **Key point:** "Every deployment goes through Git — no manual kubectl"

### 3. Show Monitoring - 1 min
- Open: https://status.alphonzojonesjr.com
- Show uptime history
- Open: https://grafana.alphonzojonesjr.com
- **Key point:** "Full observability stack"

### 4. Show Architecture - 1 min
- Terminal: `kubectl get nodes -o wide`
- Show 6 nodes (mix of bare metal + VMs)
- **Key point:** "Hybrid infrastructure — I manage everything"

### 5. Show Backup Strategy - 1 min
- Explain: Proxmox → Synology NAS → Backblaze B2
- **Key point:** "3-2-1 backup — I've actually tested restores"

---

## 💬 Talking Points by Role

### For Platform/DevOps Engineer Roles:
- "I implemented GitOps with ArgoCD — all changes auditable through Git"
- "Network policies enforce zero-trust between namespaces"
- "Automated backups with off-site replication to Backblaze B2"

### For Cloud Engineer Roles:
- "Hybrid infrastructure: Proxmox VMs + bare metal workers"
- "Cloudflare Tunnel eliminates need for public IPs"
- "Cost-optimized: ~$5/month for off-site backup of entire platform"

### For AI/ML Platform Roles:
- "Local LLM inference on Tesla P4 — no API costs"
- "Ollama + Open WebUI gives ChatGPT-like experience"
- "GPU scheduling via Kubernetes device plugin"

---

## 🔧 Live Commands to Run
```bash
# Show cluster
kubectl get nodes -o wide

# Show all running apps
kubectl get pods -A | grep -v "Completed\|kube-system" | head -30

# Show GPU allocation
kubectl describe node k8s-worker05 | grep -A5 "Allocated resources"

# Show ArgoCD apps
kubectl get applications -n argocd

# Test AI endpoint
curl -s https://ollama.alphonzojonesjr.com/api/tags | jq '.models[].name'
```

---

## ❓ Expected Questions & Answers

**Q: Why bare metal instead of cloud?**
> "Learning experience + cost. This platform would cost $500+/month on AWS. I pay ~$50/month in electricity and $5 for backup storage."

**Q: How do you handle failures?**
> "Longhorn replicates storage across nodes. Backups run weekly to NAS, then sync to Backblaze. I've tested full cluster recovery."

**Q: What's the hardest problem you solved?**
> "GPU passthrough to Kubernetes. Had to configure NVIDIA drivers, container toolkit, device plugin, and debug secure boot issues — took several hours but learned the whole stack."

**Q: How would you scale this?**
> "Add worker nodes to the cluster. Longhorn handles storage distribution. ArgoCD auto-deploys to new capacity. For AI, I'd add more GPUs or use vLLM for batching."

---

## 🔗 Quick Links for Demo

| Service | URL |
|---------|-----|
| AI Chat | https://ai.alphonzojonesjr.com |
| Platform Bot | https://chat.alphonzojonesjr.com |
| ArgoCD | https://argocd.alphonzojonesjr.com |
| Grafana | https://grafana.alphonzojonesjr.com |
| Status | https://status.alphonzojonesjr.com |
| Portfolio | https://alphonzojonesjr.com |

---

## 🛑 If Something Breaks During Demo

1. **Stay calm** — "Let me troubleshoot this live, that's part of the job"
2. Check: `kubectl get pods -A | grep -v Running`
3. Check: `kubectl logs -n <namespace> <pod>`
4. **Pivot:** "This is why we have monitoring and runbooks"

---

*Fire Snake Homelab 🐍🔥*
