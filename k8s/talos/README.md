# Talos

## Cluster Setup

- verify install disk, edit patches to match: `talosctl get disks -n <DHCP_IP> -e <DHCP_IP> --insecure`

- create & apply Talos configs, bootstrap ETCD, get kubeconfig, approve CSR

```bash
# generate base config (contains secrets)
talosctl gen config tal-clu-1 https://cp-01.tal-clu-1.hl.emerconn.com:6443

# apply generic and machine-specific patches
talosctl machineconfig patch cp.yaml \
  --patch @patch/all.yaml \
  --patch @patch/cp-01.yaml \
  -o cp-01.yaml
# repeat for cp-02 and cp-03
talosctl machineconfig patch w-01.yaml \
  --patch @patch/all.yaml \
  --patch @patch/w-01.yaml \
  -o w-01.yaml

# apply machine-specific configs
talosctl apply-config --insecure -n <cp-01-ip> --file cp-01.yaml
# repeat for cp-02 and cp-03
talosctl apply-config --insecure -n <w-01-ip> --file w-01.yaml

# bootstrap control plane
talosctl bootstrap -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

# generate kubeconfig
talosctl kubeconfig --force -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

kubectl get csr
kubectl certificate approve <CSR-NAME>
```

- install Cilium via Helm

- install `kube-prometheus-stack` via Flux

## Upgrades

### Talos

- upgrade nodes sequentially, starting with control plane
```bash
talosctl upgrade \
  -i "factory.talos.dev/metal-installer/0b4f48281e59712995bea152e8e62f3082be4ab66d2bdd0ca83cb3ce8c4509a9:v<version>" \
  -n "<node_name>"
```
  - btrfs
  - i915
  - intel-ucode
  - iscsi-tools

### Kubernetes

- run checks and pull images
```bash
talosctl upgrade-k8s -n cp-01 --to <k8s-version> --dry-run
```
- upgrade the cluster
```bash
talosctl upgrade-k8s -n cp-01 --to <k8s-version>
```
