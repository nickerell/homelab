# Internal CA for Homelab TLS

A self-signed root CA used by cert-manager to issue TLS certificates for internal `.home` services.

## Files

| File | Description |
|------|-------------|
| `bootstrap-ca.sh` | Generates the CA keypair and imports it into the cluster as a Secret. |
| `homelab-ca.crt` | The root CA certificate (distribute this to clients). |
| `homelab-ca.key` | The root CA private key (keep secret; needed to sign new certs). |

## Quick Start

```bash
cd ~/dev/homelab/certs
chmod +x bootstrap-ca.sh
./bootstrap-ca.sh
```

This will:
1. Create `homelab-ca.key` and `homelab-ca.crt` (if they don't exist).
2. Create the `homelab-ca-secret` in the `cert-manager` namespace.

## Trust the CA on Clients

### macOS
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain homelab-ca.crt
```

### iOS / iPadOS
1. AirDrop `homelab-ca.crt` to the device.
2. Settings → Profile Downloaded → Install.
3. Settings → General → About → Certificate Trust Settings → enable the CA.

## Backup / Restore

Back up `homelab-ca.key` somewhere safe (1Password, encrypted USB, etc.). Without it, cert-manager cannot renew or issue new certificates.
