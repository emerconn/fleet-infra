# notes

## get tenant credentials

```bash
kubectl get secret -n minio-tenant main-env-config -o json | jq -r '.data."config.env"' | base64 -d
```
