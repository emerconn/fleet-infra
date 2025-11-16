#!/usr/bin/bash

export GITHUB_USER=emerconnelly
export GITHUB_TOKEN=replace_me

flux bootstrap github \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=homelab \
  --branch=main \
  --path=./k8s/flux/clusters/tal-clu-1 \
  --personal
