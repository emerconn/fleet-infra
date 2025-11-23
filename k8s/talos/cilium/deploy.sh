#!/usr/bin/bash

cilium_version=1.18.4

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade cilium cilium/cilium \
    --install \
    --values values.yaml \
    --namespace kube-system \
    --version $cilium_version \
