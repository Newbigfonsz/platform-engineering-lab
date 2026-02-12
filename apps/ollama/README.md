# Ollama - Local LLM Server

GPU-accelerated LLM inference on Kubernetes.

## Hardware
- **Node:** k8s-worker05 (HP Z240)
- **GPU:** NVIDIA Tesla P4 8GB
- **Driver:** 570.211.01
- **CUDA:** 12.8

## Endpoints
- **Internal:** `http://ollama.ollama.svc:11434`
- **External:** `https://ollama.alphonzojonesjr.com`

## API Examples
```bash
# List models
curl https://ollama.alphonzojonesjr.com/api/tags

# Generate text
curl https://ollama.alphonzojonesjr.com/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello!"
}'

# Chat
curl https://ollama.alphonzojonesjr.com/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hello!"}]
}'
```

## Models Installed
- llama3.2 (3B) - General purpose
- mistral (7B) - General purpose  
- codellama (7B) - Coding

## Pull New Models
```bash
kubectl exec -it -n ollama deployment/ollama -- ollama pull <model>
```

## GPU Memory Usage
- llama3.2: ~2.7GB
- mistral: ~4.1GB
- codellama: ~3.8GB
- Total available: 7.7GB
