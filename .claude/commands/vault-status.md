Run a comprehensive Vault HA and secrets pipeline health check. Vault is critical infrastructure — External Secrets Operator and vault-agent injection both depend on it. Execute ALL checks in parallel where possible, then summarize.

## Vault Pod Status
```bash
kubectl -n vault get pods -o wide
```

## Vault Seal Status (each pod)
```bash
kubectl -n vault exec vault-0 -- vault status
```
```bash
kubectl -n vault exec vault-1 -- vault status 2>/dev/null || echo "vault-1 not found or not available"
```

## Vault Leader Check
```bash
kubectl -n vault exec vault-0 -- vault status -format=json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'active: {d.get(\"active_node\",\"unknown\")}, is_self: {d.get(\"is_self\",\"unknown\")}')" || true
```

## External Secrets Operator Health
```bash
kubectl -n external-secrets get pods
```

## ClusterSecretStore Status
```bash
kubectl get clustersecretstore -o custom-columns=NAME:.metadata.name,READY:.status.conditions[0].status,MESSAGE:.status.conditions[0].message
```

## ExternalSecret Sync Status (all namespaces)
```bash
kubectl get externalsecrets -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.conditions[0].status,MESSAGE:.status.conditions[0].message
```
Flag any ExternalSecrets where READY is not "True" — these indicate broken secret sync.

## Vault Namespace Network Policies
```bash
kubectl -n vault get networkpolicies -o wide
```
Verify the following policies exist (required for Vault to function with ESO and webhook injection):
- **allow-apiserver-webhook**: must allow ingress on port 8080 (vault-agent injector webhook)
- **allow-vault-clients**: must allow ingress on ports 8200 and 8201 (Vault API and cluster replication)

If either policy is missing, flag it as CRITICAL — ESO and vault-agent injection will fail without them.

## Vault Warning Events
```bash
kubectl -n vault get events --field-selector=type=Warning --sort-by=.lastTimestamp | tail -10
```

Provide a summary with:
- **Vault cluster health**: sealed/unsealed status of each pod, which pod is the active leader, HA mode
- **ESO connectivity**: are ESO pods running and is the ClusterSecretStore ready?
- **ExternalSecret sync failures**: list any ExternalSecrets not in Ready state with their error messages
- **Network policy verification**: confirm both required policies (allow-apiserver-webhook on 8080, allow-vault-clients on 8200/8201) are present
- **Overall status**: Healthy / Degraded / Critical
- **Actionable items**: list any issues that need attention
