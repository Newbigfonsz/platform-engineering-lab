# Vault with AWS KMS Auto-Unseal

## Prerequisites
- AWS KMS key created
- Kubernetes secret with AWS credentials:
```bash
  kubectl create secret generic vault-aws-creds -n vault \
    --from-literal=AWS_ACCESS_KEY_ID="<your-key>" \
    --from-literal=AWS_SECRET_ACCESS_KEY="<your-secret>"
```

## Install/Upgrade
```bash
helm upgrade --install vault hashicorp/vault -n vault -f values.yaml
```

## KMS Key Details
- Key ID: 63bdb59f-27af-486a-94a1-be6bc3a98976
- Region: us-east-1
- Cost: ~$1/month
