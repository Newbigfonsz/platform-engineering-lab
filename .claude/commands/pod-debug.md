Debug a pod issue. Usage: /pod-debug <namespace> <pod-name-or-label>

Investigate the pod(s) specified by the user using the arguments: $ARGUMENTS

## Get pod details
```bash
kubectl describe pod -n <namespace> <pod>
```

## Get pod logs (current and previous)
```bash
kubectl logs -n <namespace> <pod> --tail=100
kubectl logs -n <namespace> <pod> --previous --tail=50 2>/dev/null || echo "No previous logs"
```

## Check events in namespace
```bash
kubectl get events -n <namespace> --sort-by=.lastTimestamp | tail -20
```

## Check resource limits and requests
```bash
kubectl get pod -n <namespace> <pod> -o jsonpath='{range .spec.containers[*]}{.name}: limits={.resources.limits}, requests={.resources.requests}{"\n"}{end}'
```

## Check network policies affecting this namespace
```bash
kubectl get networkpolicies -n <namespace>
```

Analyze the output and provide:
- Root cause of the issue
- Whether it's related to known patterns (network policy blocking, resource limits, PVC issues)
- Recommended fix with specific commands
- Verification steps after the fix
