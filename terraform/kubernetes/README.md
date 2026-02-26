# DO NOT RUN terraform apply

These files are **unused reference material**. The infrastructure they describe was installed via raw `kubectl apply` manifests, not Terraform.

## Why this is dangerous

- **No tfstate exists** — Terraform will try to `helm install` releases that already exist as kubectl-applied resources
- **Chart versions are stale** — pinned at ingress-nginx 4.8.3, metallb 0.13.12, argocd 5.51.6. Applying would downgrade live cluster components
- **MetalLB + ingress-nginx downgrade = full outage** — all HTTP/HTTPS traffic routes through these

## What actually manages these components

| Component | Installed via | Managed by |
|-----------|--------------|------------|
| ingress-nginx | `kubectl apply` | Manual kubectl |
| MetalLB | `kubectl apply` | Manual kubectl |
| ArgoCD | `kubectl apply` | Manual kubectl |

## History

Someone ran `terraform init` here (`.terraform/` and `.terraform.lock.hcl` exist) but `terraform apply` was never executed. The IP pool and chart values were likely used as reference when doing the manual install.

## The Proxmox Terraform is real

`terraform/proxmox/` has a live tfstate and manages the VMs. That directory is safe to use. This one is not.
