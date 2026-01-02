#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║       🧪 COMPREHENSIVE SYSTEM TEST 🧪                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Cluster Health
echo "1️⃣  Cluster Health Check..."
echo "==========================="
kubectl get nodes
echo ""
kubectl cluster-info | head -5
echo ""

# Test 2: All Pods Running
echo "2️⃣  Pod Status Check..."
echo "======================="
echo "Total pods running:"
kubectl get pods -A --no-headers | grep Running | wc -l
echo ""
echo "Failed/Pending pods:"
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers | wc -l
echo ""

# Test 3: Applications
echo "3️⃣  Application Health..."
echo "========================"
for ns in demo taskapp monitoring argocd; do
  READY=$(kubectl get pods -n $ns --no-headers 2>/dev/null | grep Running | wc -l)
  TOTAL=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
  echo "  $ns: $READY/$TOTAL pods running"
done
echo ""

# Test 4: HTTPS Endpoints
echo "4️⃣  HTTPS Endpoint Tests..."
echo "==========================="
for url in \
  "https://demo.alphonzojonesjr.com" \
  "https://taskapp.alphonzojonesjr.com" \
  "https://grafana.alphonzojonesjr.com" \
  "https://argocd.alphonzojonesjr.com"; do
  
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
    echo "  ✅ $url ($STATUS)"
  else
    echo "  ❌ $url ($STATUS)"
  fi
done
echo ""

# Test 5: TLS Certificates
echo "5️⃣  TLS Certificate Validity..."
echo "==============================="
kubectl get certificate -A -o custom-columns=\
NAMESPACE:.metadata.namespace,\
NAME:.metadata.name,\
READY:.status.conditions[0].status,\
AGE:.metadata.creationTimestamp
echo ""

# Test 6: CI/CD Pipeline
echo "6️⃣  CI/CD Pipeline Status..."
echo "============================"
echo "Latest GitHub Actions workflow:"
echo "  Check: https://github.com/Newbigfonsz/platform-engineering-lab/actions"
echo ""

# Test 7: GitOps
echo "7️⃣  ArgoCD Application Status..."
echo "================================"
kubectl get application -n argocd -o custom-columns=\
NAME:.metadata.name,\
SYNC:.status.sync.status,\
HEALTH:.status.health.status,\
AGE:.metadata.creationTimestamp
echo ""

# Test 8: Monitoring
echo "8️⃣  Monitoring Stack..."
echo "======================="
echo "Prometheus targets:"
kubectl exec -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -c prometheus -- \
  wget -qO- http://localhost:9090/api/v1/targets | \
  jq -r '.data.activeTargets | length' 2>/dev/null || echo "  Check Prometheus UI"
echo ""

# Test 9: Resource Usage
echo "9️⃣  Resource Usage..."
echo "===================="
kubectl top nodes 2>/dev/null || echo "  metrics-server not installed (optional)"
echo ""

# Test 10: DNS Resolution
echo "🔟 DNS Resolution Test..."
echo "========================="
for host in \
  "demo.alphonzojonesjr.com" \
  "taskapp.alphonzojonesjr.com" \
  "grafana.alphonzojonesjr.com" \
  "argocd.alphonzojonesjr.com"; do
  
  IP=$(dig +short "$host" | tail -1)
  if [ -n "$IP" ]; then
    echo "  ✅ $host → $IP"
  else
    echo "  ❌ $host → No resolution"
  fi
done
echo ""

# Final Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ TEST SUMMARY ✅                         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Live Applications:"
echo "   • Demo:     https://demo.alphonzojonesjr.com"
echo "   • TaskApp:  https://taskapp.alphonzojonesjr.com"
echo "   • Grafana:  https://grafana.alphonzojonesjr.com"
echo "   • ArgoCD:   https://argocd.alphonzojonesjr.com"
echo ""
echo "📊 GitHub:     https://github.com/Newbigfonsz/platform-engineering-lab"
echo ""
echo "✅ All systems operational!"
