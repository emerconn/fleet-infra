# synology-csi-talos

[`synology-csi-talos`](https://github.com/zebernst/synology-csi-talos) is a Talos-specific iteration of [`synology-csi`](https://github.com/SynologyOpenSource/synology-csi)

## install

The install docs are a bit scattered. Try to follow along below.

- install the [`iscsi-tools`](https://github.com/siderolabs/extensions/tree/main/storage/iscsi-tools) Talos system extension
  - ise [Talos Linux Image Factory](https://factory.talos.dev/) for a prebuilt image and install instructions
- create a K8s secret to auth against the Synology DSM host(s), using a DSM account with full administrator permissions

  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
      name: client-info-secret
      namespace: synology-csi-talos
  type: Opaque
  stringData:
      client-info.yml: |
          clients:
          - host: 172.21.0.20
            port: 5000 (plain-text)
            https: false
            username: <username>
            password: <password>
          - host: 172.21.0.21
            port: 5001 (encrypted)
            https: true
            username: <username>
            password: <password>
  ```

- read [this Talos doc](https://www.talos.dev/v1.7/kubernetes-guides/configuration/synology-csi/)
- use [this Helm chart](https://github.com/zebernst/synology-csi-talos/tree/main/charts/synology-csi)

### `snapshotter` (optional)

Requires the following components installed

- [Volume Snapshot CRDs](https://github.com/kubernetes-csi/external-snapshotter/tree/master/client/config/crd)
- [`snapshot-controller`](https://github.com/piraeusdatastore/helm-charts/tree/main/charts/snapshot-controller)
