#!/usr/bin/bash

export GITHUB_TOKEN='<replace_me>'

flux bootstrap github \
  --token-auth \
  --owner=emerconn \
  --repository=homelab \
  --branch=main \
  --path=./k8s/flux/clusters/tal-clu-1 \
  --personal
