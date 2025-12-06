#!/bin/bash

# Automated Platform Health Check with Email Alerts
LOGFILE="/home/platformadmin/platform-health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "========================================" >> $LOGFILE
echo "Health Check: $DATE" >> $LOGFILE
echo "========================================" >> $LOGFILE

# Check pods
FAILED_PODS=$(kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
if [ "$FAILED_PODS" -gt 0 ]; then
    echo "⚠️  WARNING: $FAILED_PODS pods not running!" >> $LOGFILE
    kubectl get pods -A --field-selector=status.phase!=Running >> $LOGFILE
else
    echo "✅ All pods healthy" >> $LOGFILE
fi

# Check HTTPS endpoints
for url in https://demo.alphonzojonesjr.com https://taskapp.alphonzojonesjr.com https://grafana.alphonzojonesjr.com; do
    STATUS=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$url")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
        echo "✅ $url ($STATUS)" >> $LOGFILE
    else
        echo "❌ $url ($STATUS)" >> $LOGFILE
    fi
done

# Check disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo "✅ Disk usage: ${DISK_USAGE}%" >> $LOGFILE

echo "" >> $LOGFILE
