#!/bin/bash
echo "Starting deep cleanup..."

# Clean up failed pods
echo "Removing failed pods..."
kubectl delete pods -A --field-selector=status.phase=Failed 2>/dev/null || true

# Clean up old certificate requests
echo "Cleaning old certificate requests..."
kubectl get certificaterequest -A -o json | jq -r '.items[] | select(.status.conditions[]? | select(.type=="Ready" and .status=="False")) | "\(.metadata.namespace) \(.metadata.name)"' | while read ns name; do
  kubectl delete certificaterequest -n $ns $name 2>/dev/null || true
done

# Clean up completed jobs
echo "Removing completed jobs..."
kubectl delete jobs -A --field-selector=status.successful=1 2>/dev/null || true

# Clean system on all nodes
echo "Cleaning package caches on all nodes..."
ansible all -i ~/platform-lab/ansible/inventory/hosts.yml -b -m shell -a "apt-get clean && apt-get autoremove -y" 2>/dev/null

# Clean journal logs (keep last 7 days)
echo "Cleaning old journal logs..."
ansible all -i ~/platform-lab/ansible/inventory/hosts.yml -b -m shell -a "journalctl --vacuum-time=7d" 2>/dev/null

# Clean Docker images (if installed)
echo "Pruning Docker..."
ansible docker -i ~/platform-lab/ansible/inventory/hosts.yml -b -m shell -a "docker system prune -af || true" 2>/dev/null

echo "Deep cleanup complete!"
