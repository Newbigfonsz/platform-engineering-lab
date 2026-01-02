#!/bin/bash

while true; do
  clear
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║          🎯 PLATFORM LIVE MONITORING DASHBOARD             ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  echo "⏰ $(date)"
  echo ""
  
  echo "📊 CLUSTER NODES:"
  kubectl get nodes --no-headers | awk '{printf "  %-15s %s\n", $1, $2}'
  echo ""
  
  echo "🚀 APPLICATIONS:"
  echo "  Demo:       $(kubectl get pods -n demo --no-headers 2>/dev/null | grep Running | wc -l)/3 Running"
  echo "  TaskApp:    $(kubectl get pods -n taskapp --no-headers 2>/dev/null | grep Running | wc -l)/5 Running"
  echo "  Monitoring: $(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep Running | wc -l)/9 Running"
  echo ""
  
  echo "🔒 CERTIFICATES:"
  kubectl get certificate -A --no-headers 2>/dev/null | awk '{printf "  %-12s %-25s %s\n", $1, $2, $3}'
  echo ""
  
  echo "💾 RESOURCE USAGE (if metrics-server installed):"
  kubectl top nodes 2>/dev/null | tail -n +2 | awk '{printf "  %-15s CPU: %5s  Memory: %5s\n", $1, $2, $4}' || echo "  Install metrics-server for resource stats"
  echo ""
  
  echo "🌐 HTTP ENDPOINTS:"
  for url in demo.alphonzojonesjr.com taskapp.alphonzojonesjr.com grafana.alphonzojonesjr.com; do
    status=$(curl -s -o /dev/null -w "%{http_code}" https://$url 2>/dev/null)
    if [ "$status" = "200" ]; then
      printf "  %-40s ✅ %s\n" "$url" "$status"
    else
      printf "  %-40s ❌ %s\n" "$url" "$status"
    fi
  done
  
  echo ""
  echo "📈 Grafana: https://grafana.alphonzojonesjr.com (admin/***REMOVED***)"
  echo ""
  echo "Press Ctrl+C to exit | Refreshing every 10s..."
  sleep 10
done
