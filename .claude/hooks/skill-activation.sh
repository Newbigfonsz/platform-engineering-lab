#!/bin/bash
# Skill activation hook — matches user prompts to relevant installed skills
# Adapted from diet103/claude-code-infrastructure-showcase for K8s/platform engineering
set -e

# Read JSON input from stdin
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('prompt','').lower())" 2>/dev/null || echo "")

if [ -z "$PROMPT" ]; then
    exit 0
fi

SUGGESTIONS=""

# K8s manifest authoring
if echo "$PROMPT" | grep -qiE 'deployment|service|ingress|configmap|secret|cronjob|statefulset|daemonset|manifest|yaml.*k8s|k8s.*yaml|kubernetes.*create|create.*kubernetes'; then
    SUGGESTIONS="${SUGGESTIONS}  k8s-yaml-generator — Generate validated K8s manifests\n"
    SUGGESTIONS="${SUGGESTIONS}  k8s-yaml-validator — Validate against best practices + Kyverno policies\n"
fi

# K8s debugging
if echo "$PROMPT" | grep -qiE 'crashloop|oomkill|pending.*pod|pod.*pending|evict|not.?ready|debug.*pod|pod.*debug|troubleshoot|crash|restart.*loop|image.*pull'; then
    SUGGESTIONS="${SUGGESTIONS}  k8s-debug — K8s troubleshooting workflows + diagnostics scripts\n"
fi

# Helm
if echo "$PROMPT" | grep -qiE 'helm|chart|values\.yaml|helm.*template|helm.*install|helm.*upgrade'; then
    SUGGESTIONS="${SUGGESTIONS}  helm-generator — Generate Helm charts with best practices\n"
    SUGGESTIONS="${SUGGESTIONS}  helm-validator — Validate chart structure + CRD detection\n"
fi

# Dockerfile / container
if echo "$PROMPT" | grep -qiE 'docker|container|dockerfile|multi.?stage|image.*build|build.*image'; then
    SUGGESTIONS="${SUGGESTIONS}  dockerfile-generator — Multi-stage Dockerfiles with security hardening\n"
    SUGGESTIONS="${SUGGESTIONS}  dockerfile-validator — Security + optimization checks\n"
    SUGGESTIONS="${SUGGESTIONS}  docker-patterns — Docker Compose, networking, volume strategies\n"
fi

# Prometheus / PromQL
if echo "$PROMPT" | grep -qiE 'promql|prometheus.*query|alert.*rule|recording.*rule|prometheus.*alert|metric|grafana.*query'; then
    SUGGESTIONS="${SUGGESTIONS}  promql-generator — PromQL queries, recording rules, alerting rules\n"
    SUGGESTIONS="${SUGGESTIONS}  promql-validator — Anti-pattern detection + optimization\n"
fi

# Loki / LogQL
if echo "$PROMPT" | grep -qiE 'loki|logql|log.*query|logging.*config'; then
    SUGGESTIONS="${SUGGESTIONS}  loki-config-generator — Loki configs with Helm values examples\n"
    SUGGESTIONS="${SUGGESTIONS}  logql-generator — LogQL queries for K8s log analysis\n"
fi

# Fluent Bit
if echo "$PROMPT" | grep -qiE 'fluent.?bit|log.*collector|log.*forward|log.*pipeline'; then
    SUGGESTIONS="${SUGGESTIONS}  fluentbit-generator — Fluent Bit configs for K8s + OTel\n"
fi

# Security review
if echo "$PROMPT" | grep -qiE 'secur|vulnerab|audit|hardcoded.*secret|secret.*leak|cve|owasp|penetr|pentest'; then
    SUGGESTIONS="${SUGGESTIONS}  insecure-defaults — Detect hardcoded secrets + weak configs (Trail of Bits)\n"
    SUGGESTIONS="${SUGGESTIONS}  static-analysis — CodeQL + Semgrep static analysis (Trail of Bits)\n"
    SUGGESTIONS="${SUGGESTIONS}  security-review — OWASP checklist + cloud infrastructure security\n"
fi

# Code review / diff review
if echo "$PROMPT" | grep -qiE 'review.*diff|diff.*review|review.*pr|pr.*review|code.*review|review.*change'; then
    SUGGESTIONS="${SUGGESTIONS}  differential-review — Security-focused git diff review (Trail of Bits)\n"
    SUGGESTIONS="${SUGGESTIONS}  sharp-edges — Detect error-prone APIs + dangerous configs (Trail of Bits)\n"
fi

# Deployment / rollout
if echo "$PROMPT" | grep -qiE 'deploy|rollout|canary|blue.?green|rolling.*update|rollback|health.*check|readiness|liveness'; then
    SUGGESTIONS="${SUGGESTIONS}  deployment-patterns — Rollout strategies, K8s probes, production checklists\n"
fi

# Postgres / database
if echo "$PROMPT" | grep -qiE 'postgres|psql|pg_dump|database.*index|slow.*query|migration|schema'; then
    SUGGESTIONS="${SUGGESTIONS}  postgres-patterns — Index optimization, anti-pattern queries, config tuning\n"
fi

# Output suggestions if any matched
if [ -n "$SUGGESTIONS" ]; then
    echo ""
    echo "Relevant skills for this task:"
    echo -e "$SUGGESTIONS"
    echo "Skills are at ~/.claude/skills/ — Claude will reference them automatically."
    echo ""
fi

exit 0
