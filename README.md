# Nic's Homelab

## What and Why

### Harbor

In K8s, images are the life blood of the systems. I wanted to be in control over what images were allowed to be used, to ensure they are vetted from a security perspective yet updated to the latest versions and tested as quickly as possible. Additionally, learning how Harbor works is a great learning opportunity as it is one of the earliest CNCF Gradulated projects donated by VMWare.

### Adguard Home

Why let your Internet usage be drained away by all these DNS queries and data downloads for harvesting your personal data? Adguard is a DNS sinkhole that is able to get rid of those types of ads on all devices on your network.

## Setup

### Ubuntu Server

### K3s

### Harbor

Harbor is deployed via a Flux `HelmRelease` that consumes the official [Harbor Helm chart](https://github.com/goharbor/harbor-helm). See [`k3s/prod-cluster/tenants/harbor/README.md`](./k3s/prod-cluster/tenants/harbor/README.md) for values, post-install password rotation, and registry CA trust instructions.

Once this repo is bootstrapped with Flux, Harbor will be reconciled automatically alongside the rest of the cluster.

### Flux

1. `curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=2.0.0 bash`
1. `yay -Syy flux-bin` (my admin workstation uses Arch Linux)
1. Logged into GitHub > Settings > Developer Settings > Personal access tokens > Fine-grained tokens > made `homelab-flux-read-token-#` to only allow access to single homelab repo. Then, in permissions for Repository, allow Contents. I chose only `Read`.
1. `export GITHUB_TOKEN="{Token Here}"`
1. `flux bootstrap github --token-auth --owner=archlord333 --repository=homelab --branch=main --path=k3s/prod-cluster --personal --components="source-controller,kustomize-controller,helm-controller,notification-controller,image-reflector-controller,image-automation-controller" --interval=5m0s`

## Maintenance

### Add Flux Components (Helm / Image Automation)

If your existing Flux installation was bootstrapped without optional controllers (e.g. the original command omitted `helm-controller`, `image-reflector-controller`, or `image-automation-controller`), simply re-run the bootstrap command above from your admin workstation with all desired components included in `--components`. Flux will update `gotk-components.yaml` in this repo and in the cluster in-place without breaking existing Kustomizations.

### Flux Update Token

1. Regenerate Token in GitHub > Settings > Developer Settings > Personal access tokens > Fine-grained tokens > click `homelab-flux-read-token-#` that was recently expired, and then, regenerate a token that lasts for a chosen amount of time.
1. Update the k8s secret in flux-system.

### Accessing Homelab K3s Cluster

Use k9s and kubectl noob, as setup in my dotfiles!
