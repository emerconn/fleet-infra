# synology-csi

## talos specific install

- <https://www.talos.dev/v1.7/kubernetes-guides/configuration/synology-csi/>
- `ghcr.io/emerconnelly/synology-csi:v1.1.3` was built from the guide and is used here
- must create a secret to auth against the iscsi target(s), see guide

## snapshotter (optional) requires

- Volume Snapshot CRDs: <https://github.com/kubernetes-csi/external-snapshotter/tree/master/client/config/crd>
- snapshot-controller  <https://github.com/piraeusdatastore/helm-charts/tree/main/charts/snapshot-controller>
