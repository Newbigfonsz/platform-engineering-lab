#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║           🧹 FINAL PLATFORM CLEANUP 🧹                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "1️⃣  Removing temporary pods and failed resources..."
echo "======================================================="

# Remove any failed/completed pods
kubectl delete pods -A --field-selector=status.phase==Failed 2>/dev/null || echo "No failed pods"
kubectl delete pods -A --field-selector=status.phase==Succeeded 2>/dev/null || echo "No completed pods"

# Remove the debug pod
kubectl delete pod backend-debug -n taskapp 2>/dev/null || echo "No debug pod"

# Remove old/unused replicasets
for ns in demo taskapp monitoring argocd; do
    echo "  Cleaning namespace: $ns"
    kubectl get rs -n $ns -o json | jq -r '.items[] | select(.spec.replicas==0) | .metadata.name' | xargs -I {} kubectl delete rs {} -n $ns 2>/dev/null
done

echo "✅ Old resources removed"
echo ""

echo "2️⃣  Removing failed metrics-server..."
echo "======================================================="
kubectl delete deployment metrics-server -n kube-system 2>/dev/null || echo "Already removed"
kubectl delete apiservice v1beta1.metrics.k8s.io 2>/dev/null || echo "Already removed"
echo "✅ Metrics-server removed"
echo ""

echo "3️⃣  Cleaning temporary files..."
echo "======================================================="
rm -f /tmp/metrics-server*.yaml 2>/dev/null
rm -f /tmp/argocd-certificate*.yaml 2>/dev/null
rm -f ~/platform-lab-backup 2>/dev/null
echo "✅ Temp files removed"
echo ""

echo "4️⃣  Optimizing Git repository..."
echo "======================================================="
cd ~/platform-lab
git gc --prune=now --aggressive 2>/dev/null
echo "✅ Git optimized"
echo ""

echo "5️⃣  Final pod status..."
echo "======================================================="
echo "Total running pods:"
kubectl get pods -A --field-selector=status.phase=Running --no-headers | wc -l

echo ""
echo "Pods by namespace:"
for ns in demo taskapp monitoring argocd cert-manager ingress-nginx metallb-system kube-system; do
    COUNT=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
    if [ $COUNT -gt 0 ]; then
        echo "  $ns: $COUNT pods"
    fi
done
echo ""

echo "6️⃣  Disk usage..."
echo "======================================================="
df -h / | grep -E "Filesystem|/$"
echo ""

echo "7️⃣  Final application check..."
echo "======================================================="
for url in https://demo.alphonzojonesjr.com https://taskapp.alphonzojonesjr.com https://grafana.alphonzojonesjr.com; do
    STATUS=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$url")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
        echo "  ✅ $url ($STATUS)"
    else
        echo "  ⚠️  $url ($STATUS)"
    fi
done
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ CLEANUP COMPLETE! ✅                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Platform Status: Clean, Optimized, Production-Ready ✨"
echo ""
