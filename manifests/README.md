# TaskApp - Full-Stack Kubernetes Demo

A production-ready task management application demonstrating modern cloud-native architecture.

## Architecture
```
Internet (HTTPS)
    ↓
Nginx Ingress Controller (192.168.1.241)
    ↓ TLS Termination
    ├─→ / → Frontend Service (React SPA)
    │         ↓
    │    Frontend Pods (2 replicas)
    │         - 10.244.1.9:80
    │         - 10.244.2.11:80
    │
    └─→ /api → Backend Service (Node.js API)
              ↓
         Backend Pods (2 replicas)
              - PostgreSQL connection
              ↓
         PostgreSQL Database
              - Persistent storage on k8s-worker01
```

## Features

- **Frontend**: Modern React interface with gradient UI
- **Backend**: RESTful API with full CRUD operations
- **Database**: PostgreSQL with persistent storage
- **High Availability**: 2 replicas for frontend and backend
- **Security**: Automated TLS with Let's Encrypt
- **Load Balancing**: MetalLB + Nginx Ingress

## Deployment
```bash
# Deploy all components
kubectl apply -f manifests/postgres.yaml
kubectl apply -f manifests/backend.yaml
kubectl apply -f manifests/frontend.yaml
kubectl apply -f manifests/ingress.yaml

# Verify deployment
kubectl get pods -n taskapp
kubectl get certificate -n taskapp
kubectl get ingress -n taskapp
```

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/tasks` - List all tasks
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

## Live Demo

🌐 **https://taskapp.alphonzojonesjr.com**

## Tech Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Node.js 18, Express.js
- **Database**: PostgreSQL 15
- **Orchestration**: Kubernetes 1.28
- **Ingress**: Nginx Ingress Controller
- **Certificates**: cert-manager + Let's Encrypt
- **DNS**: AWS Route53

## Statistics

- 4 Kubernetes Deployments
- 5 Running Pods (1 DB + 2 Backend + 2 Frontend)
- 3 Services (ClusterIP)
- 1 Ingress with TLS
- Automated certificate renewal (90-day cycle)
