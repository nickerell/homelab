#!/usr/bin/env bash
set -euo pipefail

# Bootstrap an internal CA for the homelab and import it into the k3s cluster.
# Run this once from your Mac (or any machine with kubectl access to the cluster).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CA_KEY="homelab-ca.key"
CA_CRT="homelab-ca.crt"

if [[ -f "$CA_KEY" && -f "$CA_CRT" ]]; then
  echo "CA files already exist in $SCRIPT_DIR. Remove them to regenerate."
else
  echo "Generating 4096-bit RSA private key..."
  openssl genrsa -out "$CA_KEY" 4096

  echo "Generating self-signed root CA certificate (10 years)..."
  openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 \
    -subj "/CN=Homelab Internal CA" \
    -out "$CA_CRT"

  echo "CA generated:"
  echo "  $SCRIPT_DIR/$CA_CRT"
  echo "  $SCRIPT_DIR/$CA_KEY"
fi

echo ""
echo "Creating (or updating) Kubernetes Secret 'homelab-ca-secret' in namespace 'cert-manager'..."
kubectl create namespace cert-manager 2>/dev/null || true

kubectl create secret generic homelab-ca-secret \
  --from-file=ca.crt="$CA_CRT" \
  --from-file=tls.crt="$CA_CRT" \
  --from-file=tls.key="$CA_KEY" \
  --namespace=cert-manager \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Done. Next steps:"
echo "  1. Trust $CA_CRT on your devices (macOS: see below, iOS: AirDrop + install profile)."
echo "  2. Apply the ClusterIssuer: kubectl apply -f ../k3s/prod-cluster/cert-manager/cluster-issuer.yaml"
echo "  3. Commit and push the updated Ingress manifests so Flux reconciles them."
echo ""
echo "macOS trust command:"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $SCRIPT_DIR/$CA_CRT"
