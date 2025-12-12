#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║         💾 COMPLETE PLATFORM BACKUP 💾                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

BACKUP_DIR="/home/platformadmin/platform-backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup-$DATE"

mkdir -p $BACKUP_PATH

echo "Backup Location: $BACKUP_PATH"
echo ""

echo "1️⃣  Backing up Git repository..."
echo "======================================="
cp -r ~/platform-lab $BACKUP_PATH/platform-lab
echo "✅ Git repo backed up"
echo ""

echo "2️⃣  Backing up all Kubernetes resources..."
echo "======================================="
kubectl get all -A -o yaml > $BACKUP_PATH/all-resources.yaml
kubectl get configmaps -A -o yaml > $BACKUP_PATH/configmaps.yaml
kubectl get secrets -A -o yaml > $BACKUP_PATH/secrets.yaml
kubectl get pv,pvc -A -o yaml > $BACKUP_PATH/storage.yaml
kubectl get ingress -A -o yaml > $BACKUP_PATH/ingress.yaml
kubectl get certificates -A -o yaml > $BACKUP_PATH/certificates.yaml
kubectl get applications -A -o yaml > $BACKUP_PATH/argocd-applications.yaml
echo "✅ K8s resources backed up"
echo ""

echo "3️⃣  Backing up configuration files..."
echo "======================================="
cp ~/.kube/config $BACKUP_PATH/kubeconfig-backup
crontab -l > $BACKUP_PATH/crontab-backup 2>/dev/null || echo "No crontab"
echo "✅ Config files backed up"
echo ""

echo "4️⃣  Backing up PostgreSQL database..."
echo "======================================="
kubectl exec -n taskapp postgres-5985fc76f-h4qch -- pg_dump -U taskapp taskappdb > $BACKUP_PATH/postgres-dump.sql 2>/dev/null || echo "⚠️  DB backup failed (check if postgres pod name changed)"
if [ -f $BACKUP_PATH/postgres-dump.sql ] && [ -s $BACKUP_PATH/postgres-dump.sql ]; then
    echo "✅ Database backed up"
else
    echo "⚠️  Database backup empty or failed"
fi
echo ""

echo "5️⃣  Backing up platform documentation..."
echo "======================================="
mkdir -p $BACKUP_PATH/docs
cp ~/platform-lab/*.md $BACKUP_PATH/docs/ 2>/dev/null || true
cp ~/platform-lab/KNOWN-ISSUES.md $BACKUP_PATH/docs/ 2>/dev/null || true
cp ~/platform-lab/DEMO-SCRIPT.md $BACKUP_PATH/docs/ 2>/dev/null || true
echo "✅ Documentation backed up"
echo ""

echo "6️⃣  Creating compressed archive..."
echo "======================================="
cd $BACKUP_DIR
tar -czf backup-$DATE.tar.gz backup-$DATE/
ARCHIVE_SIZE=$(du -h backup-$DATE.tar.gz | cut -f1)
echo "✅ Archive created: backup-$DATE.tar.gz ($ARCHIVE_SIZE)"
echo ""

echo "7️⃣  Cleaning up temporary files..."
echo "======================================="
rm -rf $BACKUP_PATH/
echo "✅ Cleanup complete"
echo ""

echo "8️⃣  Backup summary..."
echo "======================================="
echo "Backup file: $BACKUP_DIR/backup-$DATE.tar.gz"
echo "Size: $ARCHIVE_SIZE"
echo ""

echo "Recent backups:"
ls -lht $BACKUP_DIR/*.tar.gz | head -5
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ BACKUP COMPLETE! ✅                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Backup saved to: $BACKUP_DIR/backup-$DATE.tar.gz"
echo ""
echo "To restore if needed:"
echo "  cd $BACKUP_DIR"
echo "  tar -xzf backup-$DATE.tar.gz"
echo "  cd backup-$DATE"
echo ""
echo "🔐 Keep this backup safe - it contains:"
echo "  • Complete Git repository"
echo "  • All Kubernetes resources"
echo "  • Secrets and configs"
echo "  • PostgreSQL database"
echo "  • All documentation"
echo ""
