# Rook Ceph cluster

## Wipe disks

- check disks and volumes

  ```bash
  talosctl get disks -n 172.21.0.4
  talosctl get discoveredvolumes -n 172.21.0.4
  ```

- create job to wipe disks, double-check node & disk names

  ```yaml
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: disk-wipe
    namespace: rook-ceph
  spec:
    completions: 3 # Set this to match the number of nodes in your list
    parallelism: 3 # Run all pods in parallel
    template:
      spec:
        containers:
        - name: disk-wipe
          image: ubuntu:latest
          command:
          - "/bin/bash"
          - "-c"
          - "apt-get update && apt-get install -y gdisk && sgdisk --zap-all /dev/sda"
          securityContext:
            privileged: true
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: job-name
                  operator: In
                  values:
                  - disk-wipe
              topologyKey: kubernetes.io/hostname
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                  - talos-cp-01
                  - talos-cp-02
                  - talos-cp-03
        restartPolicy: Never
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
