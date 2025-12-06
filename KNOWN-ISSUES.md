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
