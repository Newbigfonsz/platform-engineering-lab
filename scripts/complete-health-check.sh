#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║       🏥 COMPLETE PLATFORM HEALTH CHECK 🏥            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES=0

echo "1️⃣  Checking Cluster Nodes..."
echo "=============================="
NODE_STATUS=$(kubectl get nodes --no-headers | grep -v " Ready" | wc -l)
if [ $NODE_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ All nodes Ready${NC}"
    kubectl get nodes
else
    echo -e "${RED}❌ Some nodes not Ready${NC}"
    kubectl get nodes
    ISSUES=$((ISSUES + 1))
fi
echo ""

echo "2️⃣  Checking Pod Status..."
echo "=============================="
FAILED_PODS=$(kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
if [ $FAILED_PODS -eq 0 ]; then
    echo -e "${GREEN}✅ All pods Running or Succeeded${NC}"
else
    echo -e "${YELLOW}⚠️  $FAILED_PODS pods not running${NC}"
    kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
    ISSUES=$((ISSUES + 1))
fi
echo ""

echo "Pod counts by namespace:"
for ns in demo taskapp monitoring argocd cert-manager ingress-nginx metallb-system; do
    RUNNING=$(kubectl get pods -n $ns --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    TOTAL=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
    if [ $TOTAL -gt 0 ]; then
        if [ $RUNNING -eq $TOTAL ]; then
            echo -e "  ${GREEN}✅ $ns: $RUNNING/$TOTAL Running${NC}"
        else
            echo -e "  ${YELLOW}⚠️  $ns: $RUNNING/$TOTAL Running${NC}"
        fi
    fi
done
echo ""

echo "3️⃣  Checking ArgoCD Status..."
echo "=============================="
ARGOCD_STATUS=$(kubectl get application taskapp -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null)
ARGOCD_SYNC=$(kubectl get application taskapp -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null)

if [ "$ARGOCD_STATUS" = "Healthy" ] && [ "$ARGOCD_SYNC" = "Synced" ]; then
    echo -e "${GREEN}✅ ArgoCD: $ARGOCD_STATUS & $ARGOCD_SYNC${NC}"
else
    echo -e "${YELLOW}⚠️  ArgoCD: $ARGOCD_STATUS & $ARGOCD_SYNC${NC}"
    ISSUES=$((ISSUES + 1))
fi

kubectl get application -n argocd
echo ""

echo "4️⃣  Checking TLS Certificates..."
echo "=============================="
EXPIRED_CERTS=$(kubectl get certificates -A -o json | jq -r '.items[] | select(.status.conditions[]? | select(.type=="Ready" and .status!="True")) | .metadata.namespace + "/" + .metadata.name' 2>/dev/null)

if [ -z "$EXPIRED_CERTS" ]; then
    echo -e "${GREEN}✅ All certificates valid${NC}"
    kubectl get certificates -A
else
    echo -e "${YELLOW}⚠️  Some certificates need attention:${NC}"
    echo "$EXPIRED_CERTS"
    kubectl get certificates -A
    ISSUES=$((ISSUES + 1))
fi
echo ""

echo "5️⃣  Testing HTTPS Endpoints..."
echo "=============================="
for url in https://demo.alphonzojonesjr.com https://taskapp.alphonzojonesjr.com https://grafana.alphonzojonesjr.com https://argocd.alphonzojonesjr.com; do
    STATUS=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$url" 2>/dev/null)
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
        echo -e "  ${GREEN}✅ $url ($STATUS)${NC}"
    else
        echo -e "  ${RED}❌ $url ($STATUS)${NC}"
        ISSUES=$((ISSUES + 1))
    fi
done
echo ""

echo "6️⃣  Testing TaskApp API..."
echo "=============================="
API_RESPONSE=$(curl -s https://taskapp.alphonzojonesjr.com/api/tasks 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ API responding${NC}"
    echo "Response: $API_RESPONSE"
else
    echo -e "${RED}❌ API not responding${NC}"
    ISSUES=$((ISSUES + 1))
fi
echo ""

echo "7️⃣  Checking Backend Logs..."
echo "=============================="
BACKEND_HEALTHY=$(kubectl logs -n taskapp -l app=taskapp-backend --tail=5 2>/dev/null | grep -E "running|initialized" | wc -l)
if [ $BACKEND_HEALTHY -gt 0 ]; then
    echo -e "${GREEN}✅ Backend healthy${NC}"
    kubectl logs -n taskapp -l app=taskapp-backend --tail=5 | grep -E "running|initialized"
else
    echo -e "${YELLOW}⚠️  Check backend logs:${NC}"
    kubectl logs -n taskapp -l app=taskapp-backend --tail=10
fi
echo ""

echo "8️⃣  Checking Disk Usage..."
echo "=============================="
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -lt 80 ]; then
    echo -e "${GREEN}✅ Disk usage: ${DISK_USAGE}%${NC}"
else
    echo -e "${YELLOW}⚠️  Disk usage: ${DISK_USAGE}% (high)${NC}"
    ISSUES=$((ISSUES + 1))
fi
df -h / | grep -E "Filesystem|/$"
echo ""

echo "9️⃣  Checking HPA Status..."
echo "=============================="
HPA_EXISTS=$(kubectl get hpa taskapp-backend-hpa -n taskapp 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ HPA configured${NC}"
    kubectl get hpa -n taskapp
else
    echo -e "${YELLOW}⚠️  HPA not found${NC}"
fi
echo ""

echo "🔟  Summary..."
echo "=============================="
TOTAL_PODS=$(kubectl get pods -A --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -A --field-selector=status.phase=Running --no-headers | wc -l)

echo "Total Pods: $TOTAL_PODS"
echo "Running Pods: $RUNNING_PODS"
echo "Applications: 4 (Demo, TaskApp, Grafana, ArgoCD)"
echo "Namespaces: $(kubectl get namespaces --no-headers | wc -l)"
echo ""

echo "╔════════════════════════════════════════════════════════╗"
if [ $ISSUES -eq 0 ]; then
    echo -e "║          ${GREEN}✅ PLATFORM 100% HEALTHY! ✅${NC}                  ║"
else
    echo -e "║          ${YELLOW}⚠️  $ISSUES ISSUES FOUND ⚠️${NC}                        ║"
fi
echo "╚════════════════════════════════════════════════════════╝"
echo ""

if [ $ISSUES -eq 0 ]; then
    echo "🎉 Platform is production-ready and demo-ready!"
    echo ""
    echo "Quick Stats for Resume/Demo:"
    echo "  • $RUNNING_PODS pods running"
    echo "  • 4 production applications"
    echo "  • 100% HTTPS with automated TLS"
    echo "  • GitOps automation with ArgoCD"
    echo "  • Complete CI/CD pipeline"
    echo "  • Comprehensive monitoring"
else
    echo "⚠️  Review issues above before demo"
fi
echo ""
