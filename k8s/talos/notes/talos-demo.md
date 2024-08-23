# Talos Demo

## Goals

- deploy 6 node cluster using Talos
  - 3 control plane nodes
  - 3 worker nodes
- install Cilium CNI
- test Talos VIP using 172.21.0.2
- perform Talos upgrade
  - installing 1.5.6
  - upgrading to 1.6.4
- perform Kubernetes Upgrade
  - installing 1.28.6
  - upgrading to 1.29.1

## Pre-Requisites

- hypervisor & shared storage
- bash shell
- install talosctl: `curl -sL https://talos.dev/install | sh`
- install kubectl: <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>
- install helm: <https://helm.sh/docs/intro/install/#from-script>

## Infra Provisioning

- get download link to Talos 1.5.6 metal-amd64.iso: <https://github.com/siderolabs/talos/releases>
- download ISO to proxmox with name `talos-1.5.6-metal-amd64.iso`
  - notice how small the ISO file is compared to Debian & Rocky
- create VM with ISO
  - name `talos-1.5.6-metal-amd64.iso`
  - 100GiB disk
  - 4 CPU
  - 4096 GiB RAM
- convert VM to template
- clone 3 VMs for control plane nodes
  - `talos-cp-01` (on `pve-01`)
  - `talos-cp-02` (on `pve-02`)
  - `talos-cp-03` (on `pve-03`)
- clone 3 VMs for worker nodes
  - change CPU to 2 & RAM to 2048
  - `talos-w-01` (on `pve-01`)
  - `talos-w-02` (on `pve-02`)
  - `talos-w-03` (on `pve-03`)
- power on all VMs
- get IPs of all VMs (DHCP for demo)
- set environment variables for 1 control plane node & 1 worker node
  - `export CONTROL_PLANE_IP=<talos-cp-01>`
  - `export WORKER_IP=<talos-w-01>`

## Prepare Cilium CNI Config

- add the Cilium helm repo

  ```bash
  helm repo add cilium https://helm.cilium.io/
  helm repo update
  ```

- create a manifest [`cilium.yaml`](cilium.yaml) for installing Cilium CNI

  ```bash
  helm template \
      cilium \
      cilium/cilium \
      --version 1.14.0 \
      --namespace kube-system \
      --set ipam.mode=kubernetes \
      --set=kubeProxyReplacement=true \
      --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
      --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
      --set=cgroup.autoMount.enabled=false \
      --set=cgroup.hostRoot=/sys/fs/cgroup \
      --set=k8sServiceHost=localhost \
      --set=k8sServicePort=7445 > cilium.yaml
  ```

## Talos & K8s Install

- create [`patch-all.yaml`](patch-all.yaml)
  - disable installation of default CNI & kube-proxy (because Cilium is OP)
  - set Talos image to 1.5.6
    - the 1.5.6 ISO is being used, but Talos uses an image for upgrades
  - set Kubernetes images to 1.28.6

  ```yaml
  cluster:
    network:
      cni:
        name: none
    proxy:
      disabled: true
      image: registry.k8s.io/kube-proxy:v1.28.6
    apiServer:
      image: registry.k8s.io/kube-apiserver:v1.28.6
    controllerManager:
      image: registry.k8s.io/kube-controller-manager:v1.28.6
    scheduler:
      image: registry.k8s.io/kube-scheduler:v1.28.6

  machine:
    install:
      image: ghcr.io/siderolabs/installer:v1.5.6
    kubelet:
      image: ghcr.io/siderolabs/kubelet:v1.28.6
  ```

- create [`patch-cp.yaml`](patch-cp.yaml)
  - select the default interface name (my lab is limited to 1 physical NIC)
  - enable DHCP
  - enable Talos VIP with a static IP

  ```yaml
  machine:
    network:
      interfaces:
      - deviceSelector:
          busPath: "0*"
        dhcp: true
        vip:
          ip: 172.21.0.2
  ```

- generate Talos config files

  ```bash
  talosctl gen config talos-cluster https://$CONTROL_PLANE_IP:6443 \
    --config-patch @patch/patch-all.yaml \
    --config-patch-control-plane @patch/patch-cp.yaml
  ```

- configure control plane nodes

  ```bash
  talosctl apply config --insecure --nodes $CONTROL_PLANE_IP --file controlplane.yaml
  talosctl apply config --insecure --nodes <cp-02-ip> --file controlplane.yaml
  talosctl apply config --insecure --nodes <cp-03-ip> --file controlplane.yaml
  ```

- configure worker nodes

  ```bash
  talosctl apply config --insecure --nodes $WORKER_IP --file worker.yaml
  talosctl apply config --insecure --nodes <w-02-ip> --file worker.yaml
  talosctl apply config --insecure --nodes <w-03-ip> --file worker.yaml
  ```

- in the Proxmox console, wait for **`KUBELET`** to show **<span style="color:limegreen">Healthy</span>**
- configure `talosctl` to use a single worker node

  ```bash
  export TALOSCONFIG=talosconfig
  talosctl config endpoint $CONTROL_PLANE_IP
  talosctl config node $CONTROL_PLANE_IP
  ```

- bootstrap etcd onto the control plane nodes: `talosctl bootstrap`
- in the Proxmox console, wait for **`APISERVER`** to show **<span style="color:limegreen">Healthy</span>**
- configure `kubectl` & test

  ```bash
  talosctl kubeconfig .
  export KUBECONFIG=kubeconfig
  kubectl get nodes
  ```

- Talos VIP should now be avaiable
  - requires etcd for quorum
  - check if it's live: `ping 172.21.0.2`
- test Talos VIP with `talosctl`

  ```bash
  talosctl config node 172.21.0.2
  talosctl health # will fail ready check, no CNI yet
  ```

- test Talos VIP with `kubectl`

  ```bash
  cat kubeconfig | grep 'server'
  sed -i 's/server:.*/server: https:\/\/172.21.0.2:6443/' kubeconfig
  cat kubeconfig | grep 'server'
  kubectl get nodes
  ```

- install Cillium CNI

  ```bash
  kubectl apply -f cilium.yaml
  kubectl get pods -A -w
  ```

- in the Proxmox console, wait for **`READY`** to show **<span style="color:limegreen">True</span>**

## Upgrade Talos

- important notes
  - if the upgrade fails Talos will auto-rollback, or force one with `talosctl rollback`
  - `talosctl upgrade` automatically:
    - cordons itself
    - leaves etcd membership (if control plane node)
    - unmounts filesystems & wipes it's `EPHEMERAL` partition
    - upgrades & reboots
    - rejoins the cluster
    - uncordons itself
- find the desired upgrade version: <https://github.com/siderolabs/talos/releases>
- upgrade Talos nodes one at a time

  ```bash
  # control plane nodes
  talosctl upgrade --nodes $CONTROL_PLANE_IP --image ghcr.io/siderolabs/installer:v1.6.4
  talosctl upgrade --nodes <cp-02-ip> --image ghcr.io/siderolabs/installer:v1.6.4
  talosctl upgrade --nodes <cp-03-ip> --image ghcr.io/siderolabs/installer:v1.6.4
  # worker nodes
  talosctl upgrade --nodes $WORKER_IP --image ghcr.io/siderolabs/installer:v1.6.4
  talosctl upgrade --nodes <w-02-ip> --image ghcr.io/siderolabs/installer:v1.6.4
  talosctl upgrade --nodes <w-03-ip> --image ghcr.io/siderolabs/installer:v1.6.4
  ```

  - watch progress in:
    - command execution shell, and
    - Proxmox consoles, or
    - `talosctl dashboard -n <node-ip>`, and
    - `kubectl get pods -A -w`

## Upgrade Kubernetes

- important notes
  - automatically upgrades all Kubernetes components
  - non-disruptive to cluster workloads
  - all members of the cluster will be upgraded
- find the desired upgrade version: <https://github.com/kubernetes/kubernetes/releases>
- upgrade Kubernetes

  ```bash
  talosctl --nodes $CONTROL_PLANE_IP upgrade-k8s --to 1.29.1
  ```

  - watch progress in:
    - command execution shell, and
    - Proxmox consoles, or
    - `talosctl dashboard -n <node-ip>`, and
    - `kubectl get pods -A -w`

---

### Helpful Links

- <https://www.talos.dev/v1.6/introduction/system-requirements/>
- <https://www.talos.dev/v1.6/talos-guides/install/virtualized-platforms/proxmox/>
- <https://www.talos.dev/v1.6/kubernetes-guides/network/deploying-cilium/>
- <https://www.talos.dev/v1.6/talos-guides/howto/scaling-down/>
- VIP
  - <https://www.talos.dev/v1.6/talos-guides/network/vip/>
  - <https://www.talos.dev/v1.6/talos-guides/network/predictable-interface-names/>
- upgradging
  - <https://www.talos.dev/v1.6/talos-guides/upgrading-talos/>
  - <https://www.talos.dev/v1.6/kubernetes-guides/upgrading-kubernetes/>
