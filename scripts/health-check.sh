#!/bin/bash
echo "=========================================="
echo "KUBERNETES CLUSTER HEALTH CHECK"
echo "=========================================="
echo ""

echo "=== Cluster Nodes ==="
kubectl get nodes
echo ""

echo "=== System Pods Status ==="
kubectl get pods -n kube-system
kubectl get pods -n kube-flannel
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
echo ""

echo "=== Application Pods ==="
kubectl get pods -n demo
echo ""

echo "=== Services & Ingress ==="
kubectl get svc -A
kubectl get ingress -A
echo ""

echo "=== Certificates ==="
kubectl get certificates -A
echo ""

echo "=== Resource Usage ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not installed (optional)"
echo ""

echo "=== Disk Usage per Node ==="
ansible all -i ~/platform-lab/ansible/inventory/hosts.yml -b -m shell -a "echo \$(hostname): \$(df -h / | tail -1 | awk '{print \$5\" used of \"\$2}')" 2>/dev/null
echo ""

echo "=== Failed Pods (should be empty) ==="
kubectl get pods -A --field-selector=status.phase=Failed
echo ""

echo "=========================================="
echo "HEALTH CHECK COMPLETE"
echo "=========================================="
