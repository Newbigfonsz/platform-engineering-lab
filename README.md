# Platform Engineering Lab - Production Kubernetes Infrastructure

> ⚠️ **Security Note**: All credentials, IP addresses, and personal information have been redacted for security. See configuration examples in `*.example` files.

**Status**: Production-Ready ✅  
**Architecture**: 3-node Kubernetes cluster on Proxmox VE

---

## 🏗️ Infrastructure Stack

- **Hypervisor**: Proxmox VE 9.1+
- **Orchestration**: Kubernetes 1.28+
- **Automation**: Ansible 2.16+, Terraform 1.14+
- **Networking**: Flannel CNI, MetalLB LoadBalancer
- **Ingress**: Nginx Ingress Controller
- **Certificates**: cert-manager + Let's Encrypt (DNS-01)
- **Cloud Integration**: AWS Route53

---

## 🖥️ Cluster Architecture

### Control Plane (1 node)
- kube-apiserver, etcd, scheduler, controller-manager

### Worker Nodes (2 nodes)
- Container workloads distributed across workers
- Flannel CNI for pod networking (10.244.0.0/16)

### Additional Infrastructure
- Control node: DevOps tooling (Ansible, Terraform, kubectl, Helm, AWS CLI)
- Docker host: Container playground
- Desktop VM: GUI access

---

## 🚀 Features

✅ **Automated TLS**: Let's Encrypt certificates with DNS-01 challenges  
✅ **Load Balancing**: MetalLB for bare-metal LoadBalancer services  
✅ **Ingress**: Nginx Ingress Controller with TLS termination  
✅ **IaC**: Complete Ansible playbooks for cluster deployment  
✅ **Backups**: Automated etcd backups and VM snapshots  
✅ **Monitoring Ready**: Prepared for Prometheus/Grafana stack  

---

## 📁 Repository Structure
```
platform-lab/
├── ansible/
│   ├── inventory/          # Ansible inventory
│   └── playbooks/          # Deployment playbooks
│       ├── install-k8s.yml
│       ├── backup-etcd.yml
│       └── cleanup-nodes.yml
├── scripts/
│   ├── health-check.sh     # Cluster health monitoring
│   ├── backup-configs.sh   # Configuration backup
│   └── deep-clean.sh       # System cleanup
├── ARCHITECTURE.md         # Detailed architecture diagrams
├── RECOVERY.md            # Disaster recovery procedures
├── SECURITY.md            # Security guidelines
└── README.md              # This file
```

---

## 🛠️ Deployment

### Prerequisites
- Proxmox VE 8.0+
- Ubuntu 24.04 LTS VMs
- SSH access configured
- DNS provider (Route53, Cloudflare, etc.)

### Quick Start

1. **Clone the repository**
```bash
   git clone https://github.com/Newbigfonsz/platform-engineering-lab.git
   cd platform-lab
```

2. **Configure inventory**
```bash
   cp ansible/inventory/hosts.yml.example ansible/inventory/hosts.yml
   # Edit with your VM IPs and credentials
```

3. **Deploy Kubernetes**
```bash
   ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/install-k8s.yml
```

4. **Configure cert-manager**
   - Create DNS provider credentials
   - Apply ClusterIssuer configuration
   - Deploy ingress with TLS

---

## 🔐 Security

- All passwords and tokens stored in Kubernetes Secrets
- SSH key-based authentication
- TLS encryption for all ingress traffic
- Regular security updates via Ansible
- Firewall rules on hypervisor

See [SECURITY.md](SECURITY.md) for detailed security practices.

---

## 💾 Backup & Recovery

- **Configuration**: Daily automated backups
- **etcd**: Automated snapshots before changes
- **VMs**: Weekly snapshots via Proxmox
- **Recovery**: Documented procedures in [RECOVERY.md](RECOVERY.md)

---

## 📊 Monitoring (Planned)

- Prometheus for metrics collection
- Grafana for visualization
- AlertManager for notifications
- Log aggregation with Loki

---

## 🎯 Use Cases

This platform is suitable for:
- Learning Kubernetes and platform engineering
- Development and testing environments
- Small-scale production workloads
- CI/CD pipeline infrastructure
- Microservices architecture experiments

---

## 📚 Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Security Guidelines](SECURITY.md)
- [Recovery Procedures](RECOVERY.md)
- [High Availability Checklist](HA-CHECKLIST.md)

---

## 🤝 Contributing

This is a personal learning project, but suggestions and improvements are welcome!

---

## 📝 License

MIT License - Feel free to use this as a reference for your own infrastructure.

---

## 🙏 Acknowledgments

Built with open-source tools:
- Kubernetes
- Ansible
- Proxmox VE
- cert-manager
- Let's Encrypt
- And many more amazing projects!

---

**Note**: This is a reference architecture. Adapt configurations for your environment and security requirements.
