# Platform Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    PHYSICAL INFRASTRUCTURE                       │
│                                                                  │
│  Intel Xeon E5-1603 (4 cores) │ 32GB RAM │ 941GB Storage       │
│                 Proxmox VE 9.1.1 Hypervisor                     │
└───────────────────────┬──────────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
┌───────▼────────┐             ┌────────▼─────────┐
│  ZFS Storage   │             │   LVM Storage    │
│  tank-vmstore  │             │   local-lvm      │
│    465 GB      │             │     348 GB       │
│  (lz4 compress)│             │   (thin-pool)    │
└────────────────┘             └──────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      VIRTUAL MACHINES                            │
└─────────────────────────────────────────────────────────────────┘

   ┌──────────────────────────────────────────────────┐
   │          control-node (10.10.0.103)             │
   │    DevOps Command Center & Jump Box              │
   │  • Ansible  • Terraform  • kubectl  • Helm       │
   │  • AWS CLI  • Docker     • Git                   │
   └──────────────────────────────────────────────────┘

   ┌──────────────────────────────────────────────────┐
   │       docker-host (10.10.0.204)                │
   │          Container Playground                     │
   └──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│              KUBERNETES CLUSTER (1.28.15)                         │
│──────────────────────────────────────────────────────────────────│
│                                                                   │
│   ┌────────────────────────────────────────────────┐            │
│   │      k8s-cp01 (10.10.0.103)                   │            │
│   │         Control Plane Node                      │            │
│   │  • kube-apiserver  • etcd  • scheduler         │            │
│   │  • controller-manager                           │            │
│   └────────────────────────────────────────────────┘            │
│                                                                   │
│   ┌──────────────────────┐   ┌──────────────────────┐          │
│   │   k8s-worker01       │   │   k8s-worker02       │          │
│   │   10.10.0.104      │   │   10.10.0.105       │          │
│   │   Worker Node        │   │   Worker Node        │          │
│   └──────────────────────┘   └──────────────────────┘          │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    NETWORKING LAYER                               │
│──────────────────────────────────────────────────────────────────│
│                                                                   │
│   Pod Network (Flannel): 10.244.0.0/16                          │
│                                                                   │
│   ┌────────────────────┐        ┌─────────────────────┐        │
│   │  MetalLB           │        │  Nginx Ingress      │        │
│   │  LoadBalancer      │        │  Controller         │        │
│   │  10.10.0.220     │        │  10.10.0.220      │        │
│   └────────────────────┘        └─────────────────────┘        │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    SECURITY & CERTIFICATES                        │
│──────────────────────────────────────────────────────────────────│
│                                                                   │
│   ┌────────────────────────────────────────────────────┐        │
│   │           cert-manager                              │        │
│   │  • Let's Encrypt ACME                              │        │
│   │  • DNS-01 Challenge (Route53)                      │        │
│   │  • Auto-renewal (90 days)                          │        │
│   └────────────────────────────────────────────────────┘        │
│                           │                                       │
│                           ▼                                       │
│              ┌──────────────────────────┐                        │
│              │     AWS Route53          │                        │
│              │  Hosted Zone:            │                        │
│              │  Z09949422RI3FRSRW9V66   │                        │
│              └──────────────────────────┘                        │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                              │
│──────────────────────────────────────────────────────────────────│
│                                                                   │
│                  HTTPS Traffic Flow                               │
│                                                                   │
│   Internet                                                        │
│      │                                                            │
│      ▼                                                            │
│   DNS (Route53)                                                   │
│      │                                                            │
│      ▼                                                            │
│   demo.alphonzojonesjr.com → 10.10.0.220                       │
│      │                                                            │
│      ▼                                                            │
│   Nginx Ingress Controller (TLS Termination)                     │
│      │                                                            │
│      ▼                                                            │
│   nginx Service (ClusterIP: 10.99.109.133)                       │
│      │                                                            │
│      ▼                                                            │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐                     │
│   │ nginx    │  │ nginx    │  │ nginx    │                     │
│   │ pod-1    │  │ pod-2    │  │ pod-3    │                     │
│   │ worker01 │  │ worker01 │  │ worker02 │                     │
│   └──────────┘  └──────────┘  └──────────┘                     │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    BACKUP & RECOVERY                              │
│──────────────────────────────────────────────────────────────────│
│                                                                   │
│   • Config Backups: ~/platform-lab/backups/                     │
│   • etcd Snapshots: /var/backups/etcd/ (k8s-cp01)               │
│   • VM Snapshots: Proxmox snapshot system                        │
│   • Scheduled: Weekly VM backups (Sunday 2 AM)                   │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## Key Features

- **High Availability**: 3-node K8s cluster with pod distribution
- **Auto-scaling**: Ready for HPA (Horizontal Pod Autoscaler)
- **Self-healing**: Kubernetes automatically restarts failed pods
- **Load Balancing**: MetalLB + Nginx for traffic distribution
- **TLS Encryption**: Automated Let's Encrypt certificates
- **Disaster Recovery**: Multiple backup layers
- **Infrastructure as Code**: Full Ansible automation

