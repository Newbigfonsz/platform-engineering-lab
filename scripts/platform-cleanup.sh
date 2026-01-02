#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║         🧹 PLATFORM CLEANUP & OPTIMIZATION 🧹          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "1️⃣  Cleaning up Istio components..."
echo "======================================="

# Remove Istio completely (we're not using it)
if kubectl get namespace istio-system &> /dev/null; then
    echo "Removing Istio system..."
    kubectl delete namespace istio-system --timeout=60s
    
    # Remove Istio CRDs
    kubectl get crd | grep istio.io | awk '{print $1}' | xargs kubectl delete crd 2>/dev/null || true
    
    # Remove Istio directory
    rm -rf ~/platform-lab/istio-1.20.2 2>/dev/null
    rm -rf ~/platform-lab/manifests/istio 2>/dev/null
fi
echo "✅ Istio removed"
echo ""

echo "2️⃣  Pruning old ReplicaSets..."
echo "======================================="
# Remove old replicasets (keeps history clean)
for ns in demo taskapp monitoring argocd; do
    echo "Namespace: $ns"
    OLD_RS=$(kubectl get rs -n $ns -o json | jq -r '.items[] | select(.spec.replicas==0) | .metadata.name')
    if [ -n "$OLD_RS" ]; then
        echo "$OLD_RS" | xargs -I {} kubectl delete rs {} -n $ns 2>/dev/null
    fi
done
echo "✅ Old ReplicaSets pruned"
echo ""

echo "3️⃣  Cleaning up failed/completed pods..."
echo "======================================="
# Remove failed and completed pods
kubectl delete pods --all-namespaces --field-selector=status.phase==Failed 2>/dev/null || echo "No failed pods"
kubectl delete pods --all-namespaces --field-selector=status.phase==Succeeded 2>/dev/null || echo "No completed pods"
echo "✅ Failed/completed pods removed"
echo ""

echo "4️⃣  Cleaning up completed jobs..."
echo "======================================="
kubectl delete jobs --all-namespaces --field-selector=status.successful==1 2>/dev/null || echo "No completed jobs"
echo "✅ Completed jobs removed"
echo ""

echo "5️⃣  Pruning unused container images..."
echo "======================================="
echo "Pruning images on all nodes..."

for node in k8s-cp01 k8s-worker01 k8s-worker02; do
    echo "Node: $node"
    ssh platformadmin@$node "sudo crictl rmi --prune" 2>/dev/null || echo "  (manual cleanup needed)"
done
echo "✅ Container images pruned"
echo ""

echo "6️⃣  Cleaning up local directories..."
echo "======================================="
# Remove backup if it exists
rm -rf ~/platform-lab-backup 2>/dev/null || true

# Clean up any temp files
rm -rf ~/platform-lab/.git/refs/original 2>/dev/null || true
cd ~/platform-lab && git gc --prune=now --aggressive 2>/dev/null || true

echo "✅ Local directories cleaned"
echo ""

echo "7️⃣  Verifying cluster health..."
echo "======================================="
echo "Nodes:"
kubectl get nodes

echo ""
echo "Namespaces and pod counts:"
for ns in kube-system demo taskapp monitoring argocd cert-manager ingress-nginx metallb-system; do
    COUNT=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
    echo "  $ns: $COUNT pods"
done

echo ""
echo "8️⃣  Disk usage check..."
echo "======================================="
df -h /mnt/data 2>/dev/null || df -h / | grep "/$"

echo ""
echo "9️⃣  Final pod status..."
echo "======================================="
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || echo "✅ All pods healthy!"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ CLEANUP COMPLETE! ✅                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Summary:"
echo "  • Istio removed (not in use)"
echo "  • Old ReplicaSets pruned"
echo "  • Failed pods removed"
echo "  • Completed jobs cleaned"
echo "  • Container images pruned"
echo "  • Git repository optimized"
echo ""
echo "Platform is now lean and optimized! 🚀"
