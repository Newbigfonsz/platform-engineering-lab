# Known Issues

## ArgoCD TLS Certificate

**Status:** Non-critical issue  
**Impact:** ArgoCD accessible but uses self-signed certificate  
**Workaround:** Accept browser warning or add exception

### Details
- ArgoCD is accessible at https://argocd.alphonzojonesjr.com
- Currently using self-signed certificate
- All other applications (Demo, TaskApp, Grafana) have valid Let's Encrypt certificates
- Issue: cert-manager webhook unable to process ArgoCD certificate requests
- Root cause: Webhook connectivity timeout (CNI/network issue)

### Public-Facing Apps (All Working ✅)
- Demo: https://demo.alphonzojonesjr.com - Valid TLS ✅
- TaskApp: https://taskapp.alphonzojonesjr.com - Valid TLS ✅
- Grafana: https://grafana.alphonzojonesjr.com - Valid TLS ✅

### Internal Admin Tools
- ArgoCD: https://argocd.alphonzojonesjr.com - Self-signed cert (functional)

### Future Fix
If needed, can investigate Flannel CNI service mesh connectivity or reinstall cert-manager webhook. Not critical for portfolio/demo purposes as ArgoCD is internal tooling.

**Last Updated:** December 6, 2025
# Known Issues

## ArgoCD TLS Certificate

**Status:** Non-critical issue  
**Impact:** ArgoCD accessible but uses self-signed certificate  
**Workaround:** Accept browser warning or add exception

### Details
- ArgoCD is accessible at https://argocd.alphonzojonesjr.com
- Currently using self-signed certificate
- All other applications (Demo, TaskApp, Grafana) have valid Let's Encrypt certificates
- Issue: cert-manager webhook unable to process ArgoCD certificate requests
- Root cause: Webhook connectivity timeout (CNI/network issue)

### Public-Facing Apps (All Working ✅)
- Demo: https://demo.alphonzojonesjr.com - Valid TLS ✅
- TaskApp: https://taskapp.alphonzojonesjr.com - Valid TLS ✅
- Grafana: https://grafana.alphonzojonesjr.com - Valid TLS ✅

### Internal Admin Tools
- ArgoCD: https://argocd.alphonzojonesjr.com - Self-signed cert (functional)

### Future Fix
If needed, can investigate Flannel CNI service mesh connectivity or reinstall cert-manager webhook. Not critical for portfolio/demo purposes as ArgoCD is internal tooling.

**Last Updated:** December 6, 2025

## Horizontal Pod Autoscaler (HPA)

**Status:** Configured but metrics unavailable  
**Impact:** HPA policy defined, will scale when metrics-server operational

### Configuration
- **HPA Created:** taskapp-backend-hpa
- **Min Replicas:** 2
- **Max Replicas:** 10
- **CPU Target:** 70% utilization
- **Memory Target:** 80% utilization
- **Scale Up Policy:** Aggressive (100% or 4 pods per 15s)
- **Scale Down Policy:** Conservative (50% per 15s, 5min stabilization)

### Current Status
HPA configuration is in place and will automatically scale pods once metrics-server is operational. The policy demonstrates:
- Understanding of production auto-scaling requirements
- Conservative scale-down to prevent flapping
- Aggressive scale-up for traffic spikes
- Resource-based scaling triggers

### Technical Details
```yaml
Metrics:
  CPU: 70% of request (100m)
  Memory: 80% of request (128Mi)
Behavior:
  Scale Up: Max(100% increase, 4 pods) per 15s
  Scale Down: 50% decrease per 15s after 5min stabilization
```

### For Demo/Interview
Can demonstrate HPA configuration and explain scaling logic even without active metrics. Shows understanding of:
- Kubernetes autoscaling concepts
- Production scaling strategies  
- Resource management
- Performance optimization

**Note:** Metrics-server requires specific cluster networking configuration. HPA will activate when metrics become available.


## Horizontal Pod Autoscaler (HPA)

**Status:** Configured but metrics unavailable  
**Impact:** HPA policy defined, will scale when metrics-server operational

### Configuration
- **HPA Created:** taskapp-backend-hpa
- **Min Replicas:** 2
- **Max Replicas:** 10
- **CPU Target:** 70% utilization
- **Memory Target:** 80% utilization
- **Scale Up Policy:** Aggressive (100% or 4 pods per 15s)
- **Scale Down Policy:** Conservative (50% per 15s, 5min stabilization)

### Current Status
HPA configuration is in place and will automatically scale pods once metrics-server is operational. The policy demonstrates:
- Understanding of production auto-scaling requirements
- Conservative scale-down to prevent flapping
- Aggressive scale-up for traffic spikes
- Resource-based scaling triggers

### For Demo/Interview
Can demonstrate HPA configuration and explain scaling logic even without active metrics. Shows understanding of:
- Kubernetes autoscaling concepts
- Production scaling strategies  
- Resource management
- Performance optimization

**Note:** Metrics-server requires specific cluster networking configuration. HPA will activate when metrics become available.

