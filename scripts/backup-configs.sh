#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/platform-lab/backups

# Backup Ansible
tar -czf $BACKUP_DIR/ansible/ansible-${DATE}.tar.gz ~/platform-lab/ansible/

# Backup Kubernetes configs
kubectl get all --all-namespaces -o yaml > $BACKUP_DIR/kubernetes/all-resources-${DATE}.yaml
cp ~/.kube/config $BACKUP_DIR/kubernetes/kubeconfig-${DATE}

# Backup from Proxmox
ssh root@192.168.1.210 "pvesh get /cluster/backup-info --output-format json" > $BACKUP_DIR/proxmox/vm-backup-info-${DATE}.json

echo "Backup completed: ${DATE}"
