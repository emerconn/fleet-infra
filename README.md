# fleet-infra

My homelab infra, featuring horrible commit messages.

## Renovate

[Dashboard](https://developer.mend.io/github/emerconnelly/fleet-infra)

Renovate manages versions and dependecies via automated PRs. For example, Flux `HelmRelease`'s are scanned for new versions. This repo has Renovate configured as a GitHub bot via a GitHub app. (move this to a GitHub Action because it looks cooler?)

## [Tailscale](k8s/flux/infra/network/tailscale-operator.yaml)

![Tailscale Machines](https://img.shields.io/badge/Machines-242424?logo=tailscale)
![Tailscale ACL Editor](https://img.shields.io/badge/ACL%20Editor-242424?logo=tailscale)
