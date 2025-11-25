#!/usr/bin/bash

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium \
    --values ../../flux/clusters/tal-clu-1/infra/network/cilium/helm-release-values.yaml \
    --namespace kube-system
