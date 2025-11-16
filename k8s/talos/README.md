# Talos

## Cluster Setup

- verify install disk, edit patches to match: `talosctl get disks -n <ip> -e <ip> --insecure`

- create & apply Talos configs, bootstrap ETCD, get kubeconfig, approve CSRs

  ```bash
  # generate base config (contains secrets)
  talosctl gen config tal-clu-1 https://cp-01.tal-clu-1.hl.emerconn.com:6443
  mv controlplane.yaml cp.yaml && mv worker.yaml w.yaml

  # apply generic and machine-specific patches
  talosctl machineconfig patch cp.yaml \ # repeat for cp-02,-03
    --patch @patch/all.yaml \
    --patch @patch/cp-01.yaml \
    -o cp-01.yaml
  talosctl machineconfig patch w.yaml \
    --patch @patch/all.yaml \
    --patch @patch/w-01.yaml \
    -o w-01.yaml

  # apply machine-specific configs
  talosctl apply-config --insecure -n <cp-01-ip> --file cp-01.yaml # repeat for cp-02,-03
  talosctl apply-config --insecure -n <w-01-ip> --file w-01.yaml

  # bootstrap control plane
  talosctl bootstrap -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

  # generate kubeconfig
  talosctl kubeconfig --force -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

  # approve CSRs
  kubectl get csr
  kubectl certificate approve <csr-name>
  ```

- install [Cilium](./cilium.sh)

- proceed with Flux

## Upgrades

### Talos (OS upgrades)

- upgrade nodes sequentially, starting with control plane
  - `btrfs`, `i915`, `intel-ucode`, `iscsi-tools`

  ```bash
  talosctl upgrade \
    -i "factory.talos.dev/metal-installer/0b4f48281e59712995bea152e8e62f3082be4ab66d2bdd0ca83cb3ce8c4509a9:v<version>" \
    -n "<node_name>"
  ```

### Kubernetes

- run checks and pre-pull images
  ```bash
  talosctl upgrade-k8s -n cp-01 --to <k8s-version> --dry-run
  ```
- upgrade the cluster
  ```bash
  talosctl upgrade-k8s -n cp-01 --to <k8s-version>
  ```

## To Do

- TODO: figure out how/where to store secrets/keys in cp.yaml