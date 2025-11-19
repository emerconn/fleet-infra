# flux

just about everything on the clusters is deployed via flux, except for

- metrics-server
  - installed with talos
  - could be migrated to flux, but handy for cluster bootstrap debugging
- kubelet-serving-cert-approver
  - installed with talos
  - could be migrated to flux
  - required for metrics-server
- cilium
  - installed post-boostrap via helm, not with talos
  - flux depends on a CNI to work, so can't be managed with flux
- secret/sops-age -n flux-system
  - manually created
  - needed for automated secrets
  - primarily using this to GitOps the init secrets for external-secrets, vault-secrets-operator, etc.

- Force a reconcile of all flux resources with `flux reconcile kustomization flux-system --with-source`
