# how to init & bootstrap

- verify install disk, edit patches to match: `talosctl get disks -n <DHCP_IP> -e <DHCP_IP> --insecure`

- create & apply Talos configs, bootstrap ETCD, get kubeconfig, approve CSR

```bash
talosctl gen config tal-clu-1 https://cp-01.tal-clu-1.hl.emerconn.com:6443 --config-patch @patch/patch-all.yaml

talosctl machineconfig patch controlplane.yaml --patch @patch/patch-cp-01.yaml -o cp-01.yaml
talosctl machineconfig patch controlplane.yaml --patch @patch/patch-cp-02.yaml -o cp-02.yaml
talosctl machineconfig patch controlplane.yaml --patch @patch/patch-cp-03.yaml -o cp-03.yaml
talosctl machineconfig patch worker.yaml --patch @patch/patch-w-01.yaml -o w-01.yaml

talosctl apply-config --insecure -n <DHCP-IP> --file cp-01.yaml
talosctl apply-config --insecure -n <DHCP-IP> --file cp-02.yaml
talosctl apply-config --insecure -n <DHCP-IP> --file cp-03.yaml
talosctl apply-config --insecure -n <DHCP-IP> --file w-01.yaml

talosctl bootstrap -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

talosctl kubeconfig --force -n cp-01.tal-clu-1.hl.emerconn.com -e cp-01.tal-clu-1.hl.emerconn.com --talosconfig=./talosconfig

kubectl get csr
kubectl certificate approve <CSR-NAME>
```

- install Cilium via Helm w/o Prometheus service monitors

- install `kube-prometheus-stack` via Flux

- upgrade Cilium via Helm w/ Prometheus service monitors
