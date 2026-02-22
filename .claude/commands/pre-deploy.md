Validate changed Kubernetes manifests before pushing to git (ArgoCD auto-syncs on push). Run all checks and provide a GO / NO-GO recommendation.

## Step 1: Identify Changed Files

```bash
git diff --name-only
git diff --cached --name-only
```

Combine the output to get a deduplicated list of all changed files (staged + unstaged). If no files have changed, report that there is nothing to validate and stop.

Filter the list to only `.yaml` and `.yml` files. If there are no YAML files among the changes, report that no manifests were changed and give an automatic GO.

## Step 2: Validate Each YAML File

For every changed YAML/YML file, run the following checks. Track results per file (pass/fail/warning).

### 2a. YAML Syntax Validation
```bash
python3 -c "
import yaml, sys
try:
    with open(sys.argv[1]) as f:
        list(yaml.safe_load_all(f))
    print('VALID')
except Exception as e:
    print(f'INVALID: {e}')
    sys.exit(1)
" <file>
```

If a file fails YAML parsing, mark it as FAIL and skip further checks for that file.

### 2b. Server-Side Dry Run
```bash
kubectl apply --dry-run=server -f <file> 2>&1
```

If dry-run fails, mark the file as FAIL. Note: files without a `kind:` field (Helm values, Kustomization bases) are not K8s manifests — skip this check and note "skipped (not a K8s manifest)".

### 2c. Common Issue Checks

For each file that contains Kubernetes resource definitions, check:

**Missing Resource Limits**
Search for container specs that lack `resources.limits`. Warn if any container is missing CPU or memory limits.

**Missing Labels**
Check if the resource metadata has the `app.kubernetes.io/name` label. Warn if missing.

**Use of :latest Tag**
Search for `image:` references that use `:latest` or have no tag at all. Warn if found.

**New Namespace Without Network Policy**
If any changed file creates a new Namespace resource, check whether there is a corresponding `default-deny` NetworkPolicy:
```bash
kubectl get networkpolicy default-deny -n <namespace> 2>/dev/null || echo "MISSING"
```
Warn if a new namespace has no default-deny network policy.

## Step 3: Check Kyverno Policies

```bash
kubectl get clusterpolicies -o custom-columns=NAME:.metadata.name,ACTION:.spec.validationFailureAction
```

Display the active policies and their enforcement mode (Enforce vs Audit). For each changed manifest, warn if it might violate these Kyverno policies:
- **require-labels**: resources must have `app.kubernetes.io/name` label
- **disallow-privileged-containers**: no `securityContext.privileged: true`
- **require-resource-limits**: containers must have CPU and memory limits
- **disallow-latest-tag**: images must not use `:latest`
- **require-non-root**: containers must set `runAsNonRoot: true`

If any policy has `ACTION: Enforce`, failing resources will be rejected by the cluster. Flag these as errors, not just warnings.

## Step 4: Summary

Present a clear summary table:

```
FILE                          | YAML | DRY-RUN | ISSUES
------------------------------|------|---------|-------
apps/myapp/deployment.yaml    | PASS | PASS    | 1 warning (missing limits)
apps/myapp/service.yaml       | PASS | PASS    | None
manifests/bad.yaml            | FAIL | SKIP    | Invalid YAML
```

Then list all warnings and errors grouped by severity:
- **ERRORS**: Anything that will cause deployment failure (invalid YAML, dry-run failures, Kyverno Enforce violations)
- **WARNINGS**: Issues that may cause problems (missing labels, missing limits, :latest tags, audit-mode Kyverno violations, missing network policies)

## Step 5: Recommendation

Based on the results:

- **GO**: All files pass YAML validation and dry-run, no errors, at most minor warnings
- **NO-GO**: Any file has YAML errors, dry-run failures, or Kyverno Enforce violations. List what must be fixed before pushing.

Clearly state the recommendation in bold. If NO-GO, provide specific remediation steps for each failing file.

Remember: pushing to git triggers ArgoCD auto-sync. A bad manifest will cause sync failures or rejected resources cluster-wide.
