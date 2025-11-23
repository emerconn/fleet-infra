#!/usr/bin/bash

# Disable the Talos managed CoreDNS and remove existing CoreDNS resources
talosctl patch machineconfig --nodes cp-01,cp-02,cp-03,w-01 --patch '{"cluster": {"coreDNS": {"disabled": true}}}'
kubectl delete -n kube-system deployments.apps coredns
kubectl delete -n kube-system configmaps coredns
kubectl delete -n kube-system service kube-dns

# Deploy CoreDNS via Helm
helm upgrade --install coredns \
  oci://ghcr.io/coredns/charts/coredns \
  --values values.yaml \
  --namespace kube-system
