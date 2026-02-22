Check network policies for a namespace. Usage: /netpol-check <namespace>

Analyze network policies in the namespace specified by: $ARGUMENTS

## List all network policies
```bash
kubectl get networkpolicies -n <namespace> -o wide
```

## Show detailed policy rules
```bash
kubectl get networkpolicies -n <namespace> -o yaml
```

## Check if default-deny exists
```bash
kubectl get networkpolicy default-deny -n <namespace> -o yaml 2>/dev/null || echo "No default-deny policy found"
```

## Check pods in namespace
```bash
kubectl get pods -n <namespace> -o wide
```

Analyze the policies and report:
- Whether default-deny is in place
- What ingress is allowed (ports, from sources)
- What egress is allowed (ports, to destinations)
- Whether init containers can reach external registries (port 80/443) — this is a common issue
- Any gaps or recommendations

Remember: default-deny blocks pip/npm in init containers — port 80/443 egress must be explicitly allowed.
