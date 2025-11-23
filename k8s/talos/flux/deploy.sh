#!/usr/bin/bash

# Deploy the Flux Operator into the Kubernetes cluster.
# This is the new best practice method to install Flux.

export GITHUB_TOKEN='<replace_me>'

helm install flux-operator \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace

kubectl -n flux-system create secret generic flux-system \
  --from-literal=username=git \
  --from-literal=password=$GITHUB_TOKEN

REPO_ROOT=$(git rev-parse --show-toplevel)
kubectl apply -f "${REPO_ROOT}/k8s/flux/clusters/tal-clu-1/flux-system/flux-instance.yaml"
