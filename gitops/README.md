# GitOps Configuration

This directory contains Kubernetes manifests managed by ArgoCD.

## Structure
```
gitops/
├── apps/
│   ├── chatbot/
│   ├── dashboard/
│   ├── filebrowser/
│   ├── portfolio/
│   ├── taskapp/
│   └── url-shortener/
├── base/
└── overlays/
```

## Deploying with ArgoCD

1. Push this repo to GitHub
2. Apply ArgoCD applications:
```bash
   kubectl apply -f gitops/apps/portfolio/argocd-app.yaml
   kubectl apply -f gitops/apps/chatbot/argocd-app.yaml
   kubectl apply -f gitops/apps/filebrowser/argocd-app.yaml
```

3. ArgoCD will auto-sync changes from Git

## Making Changes

1. Edit the YAML files in this directory
2. Commit and push to GitHub
3. ArgoCD automatically deploys changes
