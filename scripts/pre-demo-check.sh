#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║         🎬 PRE-DEMO HEALTH CHECK 🎬                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check cluster
echo "1️⃣  Cluster Nodes:"
kubectl get nodes --no-headers | awk '{print "   " $1 ": " $2}'
echo ""

# Check pods
echo "2️⃣  Application Pods:"
for ns in demo taskapp monitoring argocd; do
  RUNNING=$(kubectl get pods -n $ns --no-headers 2>/dev/null | grep Running | wc -l)
  TOTAL=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
  echo "   $ns: $RUNNING/$TOTAL running"
done
echo ""

# Check HTTPS
echo "3️⃣  HTTPS Endpoints:"
for url in https://demo.alphonzojonesjr.com https://taskapp.alphonzojonesjr.com https://grafana.alphonzojonesjr.com https://argocd.alphonzojonesjr.com; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
    echo "   ✅ $url ($STATUS)"
  else
    echo "   ❌ $url ($STATUS)"
  fi
done
echo ""

# Check certificates
echo "4️⃣  TLS Certificates:"
kubectl get certificate -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.conditions[0].status | grep True | wc -l | xargs echo "   Valid certificates:"
echo ""

# ArgoCD status
echo "5️⃣  ArgoCD Application:"
kubectl get application -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
echo ""

echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ DEMO READY STATUS ✅                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
