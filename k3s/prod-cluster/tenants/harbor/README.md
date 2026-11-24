# Harbor

[Harbor](https://goharbor.io/) container registry deployed via Flux's `HelmRelease`.

> **Prerequisite:** The cluster must have the Flux `helm-controller` installed. If your current Flux bootstrap does not include it, re-run bootstrap with `--components="source-controller,kustomize-controller,helm-controller,notification-controller"` (see root `README.md`).

## How it works

Instead of vendoring thousands of lines of rendered Helm templates, we let Flux manage the chart directly:

1. `helm-repository.yaml` — registers the official `goharbor` Helm repository
2. `harbor-helm-release.yaml` — tells Flux to install/upgrade the `harbor` chart into the `harbor` namespace with our homelab-specific values

## Files

| File | Purpose |
|------|---------|
| `helm-repository.yaml` | `HelmRepository` CR pointing to `https://helm.goharbor.io` |
| `harbor-helm-release.yaml` | `HelmRelease` CR with inline values |

## Updating Harbor

Bump `spec.chart.spec.version` in `harbor-helm-release.yaml` and commit. Flux will upgrade automatically.

To preview what a version change would render locally:

```bash
helm repo add goharbor https://helm.goharbor.io
helm repo update
helm template harbor goharbor/harbor --version 1.15.4 \
  --namespace harbor -f <(yq '.values' harbor-helm-release.yaml)
```

## Post-install

1. **Change the default admin password**  
   The chart defaults to `Harbor12345`. Rotate it after first sync:
   ```bash
   kubectl patch secret harbor-core -n harbor --type=json \
     -p='[{"op": "replace", "path": "/data/HARBOR_ADMIN_PASSWORD", "value":"'$(echo -n "YourNewStrongPassword" | base64)'"}]'
   kubectl rollout restart deployment/harbor-core -n harbor
   ```
   Then log in at `https://harbor.home` as `admin`.

2. **Trust the homelab CA on pull nodes**  
   Because the registry serves a cert signed by the bootstrap CA (`certs/bootstrap-ca.sh`), every node that pulls images must trust it:
   ```bash
   sudo cp homelab-ca.crt /usr/local/share/ca-certificates/
   sudo update-ca-certificates
   sudo systemctl restart k3s
   ```

3. **Push / pull images**
   ```bash
   docker login harbor.home
   docker tag myimage:latest harbor.home/library/myimage:latest
   docker push harbor.home/library/myimage:latest
   ```
