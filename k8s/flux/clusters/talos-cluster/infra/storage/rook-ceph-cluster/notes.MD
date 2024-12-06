# Rook Ceph cluster

## Wipe disks & sanitize Talos ephemeral

- check disks and volumes

  ```bash
  talosctl get disks -n 172.21.0.2,172.21.0.3,172.21.0.4 | grep -e "MODEL" -e "sda"
  talosctl get discoveredvolumes -n 172.21.0.2,172.21.0.3,172.21.0.4 | grep -e "DISCOVERED" -e "sda"
  ```

- create job to wipe disks, double-check node & disk names
  - see <https://www.talos.dev/v1.8/kubernetes-guides/configuration/ceph-with-rook/>

  ```yaml
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: rook-ceph-cleanup-job
    namespace: rook-ceph
  spec:
    completions: 3 # replace with total node count
    parallelism: 3 # replace with total node count
    template:
      spec:
        restartPolicy: Never
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values: # replace with node names
                  - talos-cp-01
                  - talos-cp-02
                  - talos-cp-03
          podAntiAffinity: # ensures jobs do not schedule on same node
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: job-name
                  operator: In
                  values:
                  - rook-ceph-cleanup-job
              topologyKey: kubernetes.io/hostname
        containers:
        - name: wipe-data-disk # CHANGE DISK VARIABLE
          # talosctl get discoveredvolumes -n 172.21.0.2 # talos-cp-01
          # see https://rook.io/docs/rook/v1.9/Storage-Configuration/ceph-teardown/#zapping-devices 
          image: ubuntu
          securityContext:
            privileged: true
          command: ["/bin/bash"]
          args:
            - "-c"
            - |
              set -ex
              DISK="/dev/sda"
              apt update && apt install -y gdisk
              sgdisk --zap-all $DISK
              sleep 3
              dd if=/dev/zero bs=1M count=100 oflag=direct,dsync of="$DISK" 
              sleep 3
              blkdiscard $DISK &
              wait
              sleep 3
              gdisk -l $DISK
              echo "done!"
        - name: sanitize-talos-ephemeral
          # cephcluster CRD uses `dataDirHostPath`
          # kubectl -n rook-ceph get cephcluster -o yaml
          # log eg: init-mon-fs debug [...] -1 '/var/lib/ceph/mon/ceph-a' already exists and is not empty: monitor may already exist
          image: ubuntu
          securityContext:
            privileged: true
          command: ["/bin/bash"]
          args:
            - "-c"
            - |
              set -ex
              ls -al /var/lib
              rm -rf /var/lib/ceph /var/lib/rook
              echo "done!"
          volumeMounts:
          - name: host-var
            mountPath: /var
        - name: host-var
          hostPath:
            path: /var
  ```

## Watch cluster deployment

- looking for `HEALTH_OK`

  ```bash
  watch kubectl -n rook-ceph get cephcluster rook-ceph
  ```

## Get dashboard password

- default username `admin`

  ```bash
  kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 -d && echo
  ```

## Ceph debug pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ceph-debug
  namespace: rook-ceph
spec:
  initContainers:
  - name: config-init
    image: quay.io/ceph/ceph:v17
    command:
    - /bin/bash
    - -c
    - |
      mkdir -p /etc/ceph
      echo "[global]" > /etc/ceph/ceph.conf
      MON_IPS=\$(cat /etc/ceph/mon-endpoints/data | sed 's/[abc]=//g')
      echo "mon_host = \${MON_IPS}" >> /etc/ceph/ceph.conf
      echo "auth_cluster_required = cephx" >> /etc/ceph/ceph.conf
      echo "auth_service_required = cephx" >> /etc/ceph/ceph.conf
      echo "auth_client_required = cephx" >> /etc/ceph/ceph.conf
      cp /etc/ceph/keys/keyring /etc/ceph/ceph.client.admin.keyring
      cp -r /etc/ceph/* /mnt/config/
    volumeMounts:
    - name: mon-endpoints
      mountPath: /etc/ceph/mon-endpoints
    - name: ceph-admin-keyring
      mountPath: /etc/ceph/keys
    - name: config
      mountPath: /mnt/config
  containers:
  - name: ceph-debug
    image: quay.io/ceph/ceph:v17
    command: [ "/bin/sleep", "infinity" ]
    volumeMounts:
    - name: config
      mountPath: /etc/ceph
  volumes:
  - name: mon-endpoints
    configMap:
      name: rook-ceph-mon-endpoints
  - name: ceph-admin-keyring
    secret:
      secretName: rook-ceph-admin-keyring
  - name: config
    emptyDir: {}
```

```bash
kubectl exec -it -n rook-ceph ceph-debug -- bash
ceph status
```

## Deleting a cluster

- operator won't delete `cephcluster` resource until dependencies are deleted (e.g. CephBlockPool, CephFilesystem, etc.)

  ```bash
  kubectl delete -n rook-ceph cephcluster rook-ceph
  kubectl logs -n rook-ceph -l app=rook-ceph-operator -f # find dependencies
  kubectl edit -n rook-ceph cephblockpool <resource-name> # do for each dependency
  # remove finalizers and save
  ```

- delete all default dependencies

  ```bash
  # CephBlockPools
  kubectl patch -n rook-ceph cephblockpools.ceph.rook.io ceph-blockpool -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete -n rook-ceph cephblockpools.ceph.rook.io ceph-blockpool --wait=false
  # CephObjectStores
  kubectl patch -n rook-ceph cephobjectstores.ceph.rook.io ceph-objectstore -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete -n rook-ceph cephobjectstores.ceph.rook.io ceph-objectstore --wait=false
  # CephFileSystem
  kubectl patch -n rook-ceph cephfilesystems.ceph.rook.io ceph-filesystem -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete -n rook-ceph cephfilesystems.ceph.rook.io ceph-filesystem --wait=false
  # CephFileSystemSubVolumeGroups
  kubectl patch -n rook-ceph cephfilesystemsubvolumegroups.ceph.rook.io ceph-filesystem-csi -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete -n rook-ceph cephfilesystemsubvolumegroups.ceph.rook.io ceph-filesystem-csi --wait=false
  ```
