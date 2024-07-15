# flux

just about everything on the clusters is deployed via flux, except for:

- metrics-server (installed with talos)
  - this could be migrated to flux
- kubelet-serving-cert-approver (installed with talos)
  - this could be migrated to flux
- secret/flux-system/sops-age (manually created)
  - needed for automated secrets
  - primarily using this to GitOps the init secrets for external-secrets, vault-secrets-operator, etc.
