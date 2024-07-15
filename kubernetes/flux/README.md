# flux

just about everything on the clusters is deployed via flux, except for:

- metrics-server
  - installed with talos
  - could be migrated to flux, but handy for cluster bootstrap debugging
- kubelet-serving-cert-approver
  - installed with talos
  - could be migrated to flux
  - required for metrics-server
- secret/sops-age -n flux-system
  - manually created
  - needed for automated secrets
  - primarily using this to GitOps the init secrets for external-secrets, vault-secrets-operator, etc.
