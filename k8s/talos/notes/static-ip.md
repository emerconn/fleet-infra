# talos static IP

## prerequisites

- 3 control plane & 3 worker nodes
  - 4 CPU
  - 4096 GiB RAM
  - 100 GiB disk
- a DHCP server
- DNS recors for each node and VIP

## steps

- set DHCP IPs of all nodes

```bash
# control plane nodes
export DHCP_TALOS_CP_01=172.21.0.150
export DHCP_TALOS_CP_02=172.21.0.151
export DHCP_TALOS_CP_03=172.21.0.152
# worker nodes
export DHCP_TALOS_W_01=172.21.0.153
export DHCP_TALOS_W_02=172.21.0.154
export DHCP_TALOS_W_03=172.21.0.155
```

- set static IPs of all nodes

```bash
# control plane nodes
export STATIC_TALOS_CP_01=172.21.0.30
export STATIC_TALOS_CP_02=172.21.0.31
export STATIC_TALOS_CP_03=172.21.0.32
# worker nodes
export STATIC_TALOS_W_01=172.21.0.33
export STATIC_TALOS_W_02=172.21.0.34
export STATIC_TALOS_W_03=172.21.0.35
```

- generate controlplane.yaml & worker.yaml

```bash
talosctl gen config talos-cluster https://$DHCP_TALOS_CP_01:6443 \
  --config-patch @patch/patch-all.yaml \
  --config-patch-control-plane @patch/patch-cp.yaml \
  --config-patch-worker @patch/patch-w.yaml
```

- patch controlplane.yaml & create cp-(01-03).yaml

```bash
talosctl machineconfig patch controlplane.yaml \
  --patch @patch/patch-cp-01.yaml \
  --output cp-01.yaml
talosctl machineconfig patch controlplane.yaml \
  --patch @patch/patch-cp-02.yaml \
  --output cp-02.yaml
talosctl machineconfig patch controlplane.yaml \
  --patch @patch/patch-cp-03.yaml \
  --output cp-03.yaml
```

- patch worker.yaml & create w-(01-03).yaml

```bash
talosctl machineconfig patch worker.yaml \
  --patch @patch/patch-w-01.yaml \
  --output w-01.yaml
talosctl machineconfig patch worker.yaml \
  --patch @patch/patch-w-02.yaml \
  --output w-02.yaml
talosctl machineconfig patch worker.yaml \
  --patch @patch/patch-w-03.yaml \
  --output w-03.yaml
```

- configure all nodes (wait for reboot)

```bash
# control plane nodes
talosctl apply config --insecure --nodes $DHCP_TALOS_CP_01 --file cp-01.yaml
talosctl apply config --insecure --nodes $DHCP_TALOS_CP_02 --file cp-02.yaml
talosctl apply config --insecure --nodes $DHCP_TALOS_CP_03 --file cp-03.yaml
# worker nodes
talosctl apply config --insecure --nodes $DHCP_TALOS_W_01 --file w-01.yaml
talosctl apply config --insecure --nodes $DHCP_TALOS_W_02 --file w-02.yaml
talosctl apply config --insecure --nodes $DHCP_TALOS_W_03 --file w-03.yaml
```

- configure `talosctl` to use a single worker node & bootstrap etcd

```bash
export TALOSCONFIG=talosconfig
talosctl config endpoint $STATIC_TALOS_CP_01
talosctl config node $STATIC_TALOS_CP_01
talosctl bootstrap
```

- change control plane to static

```bash
# patch control plane nodes
talosctl patch machineconfig \
  -n $STATIC_TALOS_CP_01,$STATIC_TALOS_CP_02,$STATIC_TALOS_CP_03 \
  -p '[{"op": "replace", "path": "/cluster/controlPlane/endpoint", "value": "https://talos-vip.emer.lab:6443"}]'
# patch worker nodes
talosctl patch machineconfig \
  -n $STATIC_TALOS_W_01,$STATIC_TALOS_W_02,$STATIC_TALOS_W_03 \
  -p '[{"op": "replace", "path": "/cluster/controlPlane/endpoint", "value": "https://talos-vip.emer.lab:6443"}]'
```

- test Talos VIP with `kubectl`

```bash
talosctl kubeconfig .
export KUBECONFIG=kubeconfig
cat kubeconfig | grep 'server'
sed -i 's/server:.*/server: https:\/\/172.21.0.50:6443/' kubeconfig
cat kubeconfig | grep 'server'
kubectl get nodes
```

- clean up all generated files

```bash
rm -rf talosconfig \
  controlplane.yaml \
  cp-01.yaml \
  cp-02.yaml \
  cp-03.yaml \
  worker.yaml
```
