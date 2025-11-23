#!/usr/bin/bash

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium \
    --values values.yaml \
    --namespace kube-system
