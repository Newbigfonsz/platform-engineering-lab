from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import subprocess
import json

app = FastAPI()

def run_kubectl(cmd):
    try:
        result = subprocess.run(f"kubectl {cmd}", shell=True, capture_output=True, text=True)
        return result.stdout
    except:
        return "Error"

@app.get("/api/nodes")
def get_nodes():
    output = run_kubectl("get nodes -o json")
    return json.loads(output)

@app.get("/api/pods")
def get_pods():
    output = run_kubectl("get pods -A -o json")
    return json.loads(output)

@app.get("/api/stats")
def get_stats():
    nodes = run_kubectl("top nodes --no-headers")
    pods_count = run_kubectl("get pods -A --no-headers | wc -l")
    namespaces = run_kubectl("get ns --no-headers | wc -l")
    return {
        "nodes": nodes.strip(),
        "pods": pods_count.strip(),
        "namespaces": namespaces.strip()
    }

@app.get("/", response_class=HTMLResponse)
def dashboard():
    return """
<!DOCTYPE html>
<html>
<head>
    <title>Homelab Dashboard</title>
    <meta http-equiv="refresh" content="30">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', sans-serif; 
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff; 
            min-height: 100vh;
            padding: 20px;
        }
        .header { text-align: center; padding: 20px; }
        .header h1 { 
            font-size: 2.5em; 
            background: linear-gradient(90deg, #4ade80, #60a5fa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .header p { color: #888; margin-top: 5px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .card {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px;
            padding: 20px;
        }
        .card h2 { color: #4ade80; margin-bottom: 15px; font-size: 1.2em; }
        .stat { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .stat:last-child { border-bottom: none; }
        .stat-value { color: #60a5fa; font-weight: bold; }
        .node { padding: 10px; margin: 5px 0; background: rgba(74,222,128,0.1); border-radius: 8px; }
        .node.ready { border-left: 3px solid #4ade80; }
        .services a { 
            display: block; 
            color: #60a5fa; 
            text-decoration: none; 
            padding: 8px;
            margin: 5px 0;
            background: rgba(96,165,250,0.1);
            border-radius: 8px;
            transition: all 0.3s;
        }
        .services a:hover { background: rgba(96,165,250,0.2); transform: translateX(5px); }
        .live { 
            display: inline-block;
            width: 8px; height: 8px;
            background: #4ade80;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        .footer { text-align: center; margin-top: 40px; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏠 Homelab Dashboard</h1>
        <p><span class="live"></span>Live • Auto-refresh every 30s</p>
    </div>
    
    <div class="grid">
        <div class="card">
            <h2>📊 Cluster Stats</h2>
            <div id="stats">Loading...</div>
        </div>
        
        <div class="card">
            <h2>🖥️ Nodes</h2>
            <div id="nodes">Loading...</div>
        </div>
        
        <div class="card">
            <h2>🌐 Services</h2>
            <div class="services">
                <a href="https://alphonzojonesjr.com" target="_blank">🏠 Portfolio</a>
                <a href="https://taskapp.alphonzojonesjr.com" target="_blank">✅ TaskApp</a>
                <a href="https://chat.alphonzojonesjr.com" target="_blank">🤖 AI Chat</a>
                <a href="https://short.alphonzojonesjr.com" target="_blank">🔗 URL Shortener</a>
                <a href="https://code.alphonzojonesjr.com" target="_blank">💻 Code Server</a>
                <a href="https://argocd.alphonzojonesjr.com" target="_blank">🔄 ArgoCD</a>
                <a href="https://grafana.alphonzojonesjr.com" target="_blank">📈 Grafana</a>
                <a href="https://vault.alphonzojonesjr.com" target="_blank">🔐 Vault</a>
                <a href="https://status.alphonzojonesjr.com" target="_blank">📊 Status</a>
            </div>
        </div>
        
        <div class="card">
            <h2>🔧 Quick Actions</h2>
            <div class="services">
                <a href="https://k8s.alphonzojonesjr.com" target="_blank">☸️ K8s Dashboard</a>
                <a href="https://dns.alphonzojonesjr.com" target="_blank">🌐 Technitium DNS</a>
                <a href="https://pulse.alphonzojonesjr.com" target="_blank">💓 Pulse</a>
                <a href="https://registry.alphonzojonesjr.com" target="_blank">📦 Harbor Registry</a>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>Alphonzo Jones Jr. • Platform Engineering Lab • 15 Services Running</p>
    </div>
    
    <script>
        async function loadStats() {
            try {
                const res = await fetch('/api/stats');
                const data = await res.json();
                document.getElementById('stats').innerHTML = `
                    <div class="stat"><span>Total Pods</span><span class="stat-value">${data.pods}</span></div>
                    <div class="stat"><span>Namespaces</span><span class="stat-value">${data.namespaces}</span></div>
                `;
            } catch(e) {
                document.getElementById('stats').innerHTML = '<p>Error loading stats</p>';
            }
        }
        
        async function loadNodes() {
            try {
                const res = await fetch('/api/nodes');
                const data = await res.json();
                let html = '';
                data.items.forEach(node => {
                    const name = node.metadata.name;
                    const ready = node.status.conditions.find(c => c.type === 'Ready')?.status === 'True';
                    html += `<div class="node ${ready ? 'ready' : ''}">
                        <strong>${name}</strong><br>
                        <small>${ready ? '✅ Ready' : '❌ Not Ready'}</small>
                    </div>`;
                });
                document.getElementById('nodes').innerHTML = html;
            } catch(e) {
                document.getElementById('nodes').innerHTML = '<p>Error loading nodes</p>';
            }
        }
        
        loadStats();
        loadNodes();
    </script>
</body>
</html>
"""
