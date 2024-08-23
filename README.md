# fleet-infra

My homelab infra, featuring horrible commit messages.

## Renovate

[![Renovate Dashboard](https://img.shields.io/badge/Dashboard-1a1f6c?logo=renovate)](https://developer.mend.io/github/emerconnelly/fleet-infra)

Configured as a [GitHub app](https://github.com/apps/renovate) (migrate to GitHub Action because it looks cooler?)

## k8s external

### Cloudflare

[![Cloudflare DNS Records](https://img.shields.io/badge/DNS_Records-f38020?logo=cloudflare&logoColor=000)](https://dash.cloudflare.com/923309f860b1a7e801fd81224c5f56c9/emerconnelly.com/dns/records)
[![Cloudflare Audit Log](https://img.shields.io/badge/Audit_Log-f38020?logo=cloudflare&logoColor=000)](https://dash.cloudflare.com/923309f860b1a7e801fd81224c5f56c9/audit-log)
[![Cloudflare API Tokens](https://img.shields.io/badge/API_Tokens-f38020?logo=cloudflare&logoColor=000)](https://dash.cloudflare.com/profile/api-tokens)

Using domain `emerconnelly.com` for [`cert-manager`](https://cert-manager.io/)'s [Let's Encrypt](https://letsencrypt.org/) [ACME DNS01 Challenge Provider](https://cert-manager.io/docs/configuration/acme/dns01/)

### Tailscale

[![Tailscale Machines](https://img.shields.io/badge/Machines-242424?logo=tailscale)](https://login.tailscale.com/admin/machines)
[![Tailscale ACL Editor](https://img.shields.io/badge/ACL%20Editor-242424?logo=tailscale)](https://login.tailscale.com/admin/machines)

Exposing the K8s API, ingress & egress to a tailnet
 
### Vault Secrets | HashiCorp Cloud Platform

[![HCP Vault Secrets](https://img.shields.io/badge/Vault_Secrets-000?logo=hashicorp)](https://portal.cloud.hashicorp.com/services/secrets?project_id=c9dc34a9-87d7-4e2d-9a1c-3d3e759f8261)

## k8s internal

- Hubble UI [![Cilium Hubble UI](https://img.shields.io/badge/Hubble_UI-f8c517?logo=cilium&logoColor=000)](https://openobserve.homelab.emerconnelly.com/)

### OpenObserve

[![OpenObserve Home](https://img.shields.io/badge/Home-651708)](https://openobserve.homelab.emerconnelly.com/)

