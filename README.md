# Platform Engineering Lab - Production Kubernetes Infrastructure

**Built**: December 2025  
**Status**: Production-Ready ✅  
**Uptime Target**: 99.9%

---

## 🏗️ Architecture Overview

### Infrastructure Stack
- **Hypervisor**: Proxmox VE 9.1.1 (Debian 12 Bookworm)
- **Orchestration**: Kubernetes 1.28.15 (3-node cluster)
- **Automation**: Ansible 2.16.3
- **IaC**: Terraform v1.14.0 (configured)
- **Networking**: Flannel CNI + MetalLB LoadBalancer
- **Ingress**: Nginx Ingress Controller
- **Certificates**: cert-manager + Let's Encrypt (DNS-01)
- **DNS Provider**: AWS Route53

### Physical Resources
- **CPU**: Intel Xeon E5-1603 (4 cores @ performance mode)
- **Memory**: 32GB DDR3 (8GB allocated to ZFS ARC, 24GB for VMs)
- **Storage**: 
  - Drive 1 (sda): 465GB ZFS pool (`tank-vmstore`) with lz4 compression
  - Drive 2 (sdb): 476GB LVM-thin (`local-lvm`)
  - Total VM Storage: ~800GB

---

## 🖥️ Virtual Machines

| VM ID | Hostname | Purpose | vCPU | RAM | Disk | IP Address | OS |
|-------|----------|---------|------|-----|------|------------|-----|
| 100 | ubuntu-desktop-01 | GUI Workstation | 4 | 8GB | 100GB | 192.168.1.210 | Ubuntu 24.04 Desktop |
| 101 | control-node | DevOps Command Center | 2 | 4GB | 32GB | 192.168.1.49 | Ubuntu 24.04 Server |
| 102 | docker-host | Container Playground | 2 | 4GB | 97GB | 192.168.1.204 | Ubuntu 24.04 Server |
| 103 | k8s-cp01 | Kubernetes Control Plane | 2 | 4GB | 65GB | 192.168.1.41 | Ubuntu 24.04 Server |
| 104 | k8s-worker01 | Kubernetes Worker | 2 | 4GB | 97GB | 192.168.1.175 | Ubuntu 24.04 Server |
| 105 | k8s-worker02 | Kubernetes Worker | 2 | 4GB | 97GB | 192.168.1.80 | Ubuntu 24.04 Server |
| 9000 | ubuntu-template | Cloud-init Template | - | 2GB | 33GB | - | Ubuntu 24.04 Server |

**Resource Allocation**: 14 vCPUs, 28GB RAM (leaving 4GB for Proxmox host)

---

## 🔧 Control Node Tools

The control-node (192.168.1.49) serves as the central management hub with:

- **Ansible** 2.16.3 - Infrastructure automation
- **Terraform** v1.14.0 - Infrastructure as Code
- **kubectl** v1.34.2 - Kubernetes CLI
- **Helm** v3.19.2 - Kubernetes package manager
- **AWS CLI** 2.32.6 - AWS integration
- **Docker** 29.1.1 - Container runtime
- **Git** - Version control (configured for GitHub: Newbigfonsz)

**SSH Access**: `ssh platformadmin@192.168.1.49`  
**Password**: ***REMOVED***

---

## ☸️ Kubernetes Cluster Details

### Cluster Configuration
- **Control Plane**: k8s-cp01 (192.168.1.41)
- **Workers**: k8s-worker01, k8s-worker02
- **CNI**: Flannel (pod network: 10.244.0.0/16)
- **Service CIDR**: Default
- **Container Runtime**: containerd
- **DNS**: CoreDNS (2 replicas)

### Network Services
- **Ingress Controller**: Nginx (192.168.1.241)
- **LoadBalancer**: MetalLB (IP pool: 192.168.1.240-241)

### Certificate Management
- **Issuer**: Let's Encrypt (ACME)
- **Challenge Type**: DNS-01 via Route53
- **Hosted Zone**: Z09949422RI3FRSRW9V66
- **Auto-renewal**: Yes (90 days)

---

## 🌐 Deployed Applications

### Demo Application
- **URL**: https://demo.alphonzojonesjr.com
- **Service**: nginx (3 replicas)
- **TLS Certificate**: Valid until March 3, 2026
- **LoadBalancer IP**: 192.168.1.240
- **Ingress IP**: 192.168.1.241

**Test Access**:
```bash
curl https://demo.alphonzojonesjr.com
curl http://192.168.1.240
```

---

## 🔐 Security & Credentials

### Proxmox VE
- **Web UI**: https://192.168.1.210:8006
- **User**: root@pam
- **Password**: ***REMOVED***

### VM Access
- **User**: platformadmin
- **Password**: ***REMOVED***
- **SSH Key**: Ed25519 (configured on control-node)

### AWS Integration
- **IAM User**: cert-manager
- **Account**: ***REMOVED***
- **Permissions**: Route53 (ChangeResourceRecordSets, GetChange, List*)

### Kubernetes
- **Kubeconfig**: `/home/platformadmin/.kube/config` (on control-node)
- **Admin Access**: Full cluster admin via kubeconfig

---

## 💾 Backup & Recovery

### Backup Locations
- **Config Backups**: `~/platform-lab/backups/`
  - Ansible configurations
  - Kubernetes resources
  - Kubeconfig
- **etcd Backups**: `/var/backups/etcd/` (on k8s-cp01)
- **VM Snapshots**: Proxmox (baseline snapshots created)
- **Proxmox Backups**: `/var/lib/vz/dump/` (weekly via cron)

### Backup Scripts
```bash
# Manual backup
~/platform-lab/scripts/backup-configs.sh

# etcd backup
ansible-playbook -i ~/platform-lab/ansible/inventory/hosts.yml \
  ~/platform-lab/ansible/playbooks/backup-etcd.yml

# VM snapshot
ssh root@192.168.1.210 "qm snapshot <VMID> snapshot-$(date +%Y%m%d)"
```

### Recovery Procedures
See: `~/platform-lab/RECOVERY.md`

---

## 📊 Monitoring & Maintenance

### Health Check
```bash
~/platform-lab/scripts/health-check.sh
```

### System Cleanup
```bash
~/platform-lab/scripts/deep-clean.sh
```

### Resource Monitoring
```bash
# Check cluster resources
kubectl top nodes
kubectl get pods -A

# Check disk usage
ansible all -i ~/platform-lab/ansible/inventory/hosts.yml \
  -b -m shell -a "df -h /"
```

---

## 🚀 Common Operations

### Deploy New Application
```bash
kubectl create namespace <app-name>
kubectl create deployment <app-name> --image=<image> -n <app-name>
kubectl expose deployment <app-name> --port=80 --type=LoadBalancer -n <app-name>
```

### Create TLS Certificate
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: <cert-name>
  namespace: <namespace>
spec:
  secretName: <secret-name>
  issuerRef:
    name: letsencrypt-dns
    kind: ClusterIssuer
  dnsNames:
    - <domain.com>
```

### Scale Application
```bash
kubectl scale deployment <name> --replicas=<count> -n <namespace>
```

---

## 📈 Performance Optimizations

### Applied Optimizations
- ✅ CPU governors set to "performance"
- ✅ Swappiness reduced to 10 (VM host optimization)
- ✅ ZFS ARC limited to 8GB (prevents memory contention)
- ✅ ZFS compression enabled (lz4)
- ✅ IOMMU enabled (48 groups for PCIe passthrough)
- ✅ Kernel modules loaded (overlay, br_netfilter)
- ✅ Sysctl optimizations for Kubernetes networking

---

## 🔄 Maintenance Schedule

### Daily
- Automatic etcd backups (configured)
- Journal log rotation (7-day retention)

### Weekly
- VM backups (Sundays 2:00 AM)
- System package updates review

### Monthly
- Disaster recovery drill
- Certificate expiration check
- Capacity planning review

---

## 📚 Reference Documentation

### Official Docs
- Proxmox: https://pve.proxmox.com/wiki/
- Kubernetes: https://kubernetes.io/docs/
- cert-manager: https://cert-manager.io/docs/
- Ansible: https://docs.ansible.com/

### Key Configuration Files
```
platform-lab/
├── ansible/
│   ├── inventory/hosts.yml          # Inventory
│   ├── playbooks/
│   │   ├── install-k8s.yml         # K8s deployment
│   │   ├── backup-etcd.yml         # etcd backup
│   │   └── cleanup-nodes.yml       # System cleanup
│   └── ansible.cfg
├── backups/
│   ├── ansible/                    # Ansible backups
│   ├── kubernetes/                 # K8s resource backups
│   └── proxmox/                    # Proxmox metadata
├── scripts/
│   ├── backup-configs.sh           # Backup automation
│   ├── health-check.sh             # Health monitoring
│   └── deep-clean.sh               # System cleanup
├── demo-ingress-fixed.yaml         # Working ingress config
└── RECOVERY.md                     # Recovery procedures
```

---

## 🎯 Next Steps / Roadmap

### Phase 1: Monitoring (Planned)
- [ ] Deploy Prometheus + Grafana
- [ ] Configure alerting
- [ ] Create custom dashboards

### Phase 2: CI/CD (Planned)
- [ ] Deploy ArgoCD (GitOps)
- [ ] Configure GitHub Actions
- [ ] Automated deployments

### Phase 3: Advanced Features (Planned)
- [ ] Service mesh (Istio/Linkerd)
- [ ] Distributed tracing
- [ ] Log aggregation (ELK/Loki)

### Phase 4: Multi-Cloud (Planned)
- [ ] AWS EKS integration
- [ ] Hybrid cloud networking
- [ ] Disaster recovery to cloud

---

## 🏆 Achievements

- ✅ Built production-grade Kubernetes cluster from scratch
- ✅ Automated TLS certificate management
- ✅ Integrated cloud services (AWS Route53)
- ✅ Implemented comprehensive backup strategy
- ✅ Infrastructure as Code with Ansible
- ✅ Zero-downtime deployments capability
- ✅ Enterprise-level security (TLS, RBAC)

---

## 📝 Notes

**Created**: December 2025  
**Author**: Platform Engineering Lab  
**Contact**: ***REMOVED***  
**GitHub**: Newbigfonsz

**This infrastructure represents enterprise-grade platform engineering practices suitable for production workloads.**

---

## 🙏 Acknowledgments

Built with patience, determination, and a lot of troubleshooting! Special thanks to the open-source community for amazing tools like Kubernetes, Ansible, cert-manager, and Proxmox.

