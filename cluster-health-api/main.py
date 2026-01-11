from flask import Flask, jsonify
from flask_cors import CORS
from kubernetes import client, config
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Load Kubernetes config
try:
    config.load_incluster_config()
except:
    config.load_kube_config()

v1 = client.CoreV1Api()
apps_v1 = client.AppsV1Api()

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.utcnow().isoformat()})

@app.route('/api/cluster')
def cluster_info():
    """Get overall cluster information"""
    try:
        nodes = v1.list_node()
        pods = v1.list_pod_for_all_namespaces()
        namespaces = v1.list_namespace()
        
        # Count pod statuses
        running = sum(1 for p in pods.items if p.status.phase == "Running")
        pending = sum(1 for p in pods.items if p.status.phase == "Pending")
        failed = sum(1 for p in pods.items if p.status.phase == "Failed")
        
        # Count node statuses
        ready_nodes = 0
        for node in nodes.items:
            for condition in node.status.conditions:
                if condition.type == "Ready" and condition.status == "True":
                    ready_nodes += 1
        
        return jsonify({
            "cluster": {
                "nodes": {
                    "total": len(nodes.items),
                    "ready": ready_nodes
                },
                "pods": {
                    "total": len(pods.items),
                    "running": running,
                    "pending": pending,
                    "failed": failed
                },
                "namespaces": len(namespaces.items)
            },
            "timestamp": datetime.utcnow().isoformat()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/nodes')
def nodes_info():
    """Get detailed node information"""
    try:
        nodes = v1.list_node()
        node_list = []
        
        for node in nodes.items:
            # Get node status
            status = "Unknown"
            for condition in node.status.conditions:
                if condition.type == "Ready":
                    status = "Ready" if condition.status == "True" else "NotReady"
            
            # Get resource info
            allocatable = node.status.allocatable
            capacity = node.status.capacity
            
            node_list.append({
                "name": node.metadata.name,
                "status": status,
                "roles": [k.replace("node-role.kubernetes.io/", "") for k in node.metadata.labels.keys() if k.startswith("node-role.kubernetes.io/")],
                "cpu": {
                    "capacity": capacity.get("cpu", "0"),
                    "allocatable": allocatable.get("cpu", "0")
                },
                "memory": {
                    "capacity": capacity.get("memory", "0"),
                    "allocatable": allocatable.get("memory", "0")
                },
                "pods": {
                    "capacity": capacity.get("pods", "0"),
                    "allocatable": allocatable.get("pods", "0")
                },
                "created": node.metadata.creation_timestamp.isoformat() if node.metadata.creation_timestamp else None
            })
        
        return jsonify({"nodes": node_list, "timestamp": datetime.utcnow().isoformat()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/namespaces')
def namespaces_info():
    """Get namespace information with pod counts"""
    try:
        namespaces = v1.list_namespace()
        pods = v1.list_pod_for_all_namespaces()
        
        # Count pods per namespace
        pod_counts = {}
        for pod in pods.items:
            ns = pod.metadata.namespace
            if ns not in pod_counts:
                pod_counts[ns] = {"running": 0, "total": 0}
            pod_counts[ns]["total"] += 1
            if pod.status.phase == "Running":
                pod_counts[ns]["running"] += 1
        
        ns_list = []
        for ns in namespaces.items:
            name = ns.metadata.name
            counts = pod_counts.get(name, {"running": 0, "total": 0})
            ns_list.append({
                "name": name,
                "status": ns.status.phase,
                "pods": counts,
                "created": ns.metadata.creation_timestamp.isoformat() if ns.metadata.creation_timestamp else None
            })
        
        return jsonify({"namespaces": ns_list, "timestamp": datetime.utcnow().isoformat()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/deployments')
def deployments_info():
    """Get all deployments"""
    try:
        deployments = apps_v1.list_deployment_for_all_namespaces()
        
        dep_list = []
        for dep in deployments.items:
            dep_list.append({
                "name": dep.metadata.name,
                "namespace": dep.metadata.namespace,
                "replicas": {
                    "desired": dep.spec.replicas or 0,
                    "ready": dep.status.ready_replicas or 0,
                    "available": dep.status.available_replicas or 0
                },
                "image": dep.spec.template.spec.containers[0].image if dep.spec.template.spec.containers else None,
                "created": dep.metadata.creation_timestamp.isoformat() if dep.metadata.creation_timestamp else None
            })
        
        return jsonify({"deployments": dep_list, "timestamp": datetime.utcnow().isoformat()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/services')
def services_info():
    """Get service status for platform services"""
    services = [
        {"name": "Portfolio", "url": "alphonzojonesjr.com"},
        {"name": "ArgoCD", "url": "argocd.alphonzojonesjr.com"},
        {"name": "Grafana", "url": "grafana.alphonzojonesjr.com"},
        {"name": "Vault", "url": "vault.alphonzojonesjr.com"},
        {"name": "Chatbot", "url": "chat.alphonzojonesjr.com"},
        {"name": "URL Shortener", "url": "short.alphonzojonesjr.com"},
        {"name": "TaskApp", "url": "taskapp.alphonzojonesjr.com"},
        {"name": "Dashboard", "url": "dash.alphonzojonesjr.com"},
        {"name": "Uptime Kuma", "url": "status.alphonzojonesjr.com"},
        {"name": "Code Server", "url": "code.alphonzojonesjr.com"},
        {"name": "Harbor", "url": "registry.alphonzojonesjr.com"},
        {"name": "FileBrowser", "url": "files.alphonzojonesjr.com"},
    ]
    
    return jsonify({"services": services, "timestamp": datetime.utcnow().isoformat()})

@app.route('/api/pods/<namespace>')
def pods_by_namespace(namespace):
    """Get pods in a specific namespace"""
    try:
        pods = v1.list_namespaced_pod(namespace)
        
        pod_list = []
        for pod in pods.items:
            # Calculate restarts
            restarts = 0
            if pod.status.container_statuses:
                restarts = sum(c.restart_count for c in pod.status.container_statuses)
            
            pod_list.append({
                "name": pod.metadata.name,
                "status": pod.status.phase,
                "ready": all(c.ready for c in pod.status.container_statuses) if pod.status.container_statuses else False,
                "restarts": restarts,
                "node": pod.spec.node_name,
                "created": pod.metadata.creation_timestamp.isoformat() if pod.metadata.creation_timestamp else None
            })
        
        return jsonify({"namespace": namespace, "pods": pod_list, "timestamp": datetime.utcnow().isoformat()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
