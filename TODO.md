# TODO

- deploy kube-prometheus-stack into own components
  - can give pods shorter/better names

- install CRDs separately from helm charts
  - kube-prometheus-stack
  - cert-manager

- fix wildcard dns entry in AdGuard (*.hl.emerconn.com breaks flux)

- use install/ugrade crds: CreateReplace for all helm charts installing CRDs

- use OCI Helm repos where possible, review all existing HTTPS Helm repos

- use config map generator to patch helm release values

- make all base infra configs use a folder, so no single yaml files for a helm release
  - split up namespace and helm release

- use more explicit file names for overlay configs, and split patches into own files
  - instead of 'patch.yaml' use 'helm-values-patch.yaml' & 'git-repo-patch.yaml'

- configure dependencies
  - Use dependencies for Layers, not Resources.
  - Layer 1 (System): CRDs, Controllers (Cilium, Cert-Manager).
  - Layer 2 (Config): Gateways, ClusterIssuers (Things that use Layer 1 CRDs).
  - Layer 3 (Apps): HTTPRoutes, Deployments (Things that use Layer 2).
  - You usually only need to define dependencies between these big layers (e.g., "Make sure System is ready before applying Apps"), not between individual files.
