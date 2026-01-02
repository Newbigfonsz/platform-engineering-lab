#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

echo "Starting backup..."

# Backup all manifests
kubectl get all -A -o yaml > $BACKUP_DIR/all-resources.yaml

# Backup configmaps
kubectl get configmaps -A -o yaml > $BACKUP_DIR/configmaps.yaml

# Backup PVCs
kubectl get pvc -A -o yaml > $BACKUP_DIR/pvcs.yaml

# Backup PostgreSQL
kubectl exec -n taskapp deploy/postgres -- pg_dump -U taskapp taskappdb > $BACKUP_DIR/taskapp-db.sql 2>/dev/null

# Backup Technitium config
ssh -o StrictHostKeyChecking=no ubuntu@10.10.0.105 "sudo tar czf /tmp/technitium.tar.gz /mnt/data/technitium" 2>/dev/null
scp -o StrictHostKeyChecking=no ubuntu@10.10.0.105:/tmp/technitium.tar.gz $BACKUP_DIR/ 2>/dev/null

echo "Backup completed: $BACKUP_DIR"
ls -la $BACKUP_DIR
