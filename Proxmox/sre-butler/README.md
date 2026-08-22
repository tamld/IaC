# Proxmox Autonomous SRE Butler (`CT121`)

## Deployment Specifications
- **ID**: `CT121`
- **Hostname**: `svc-butler-prod`
- **IP**: `192.168.10.121/24`
- **Gateway**: `192.168.10.1`
- **Resources**: 2 Cores, 256MB RAM, 256MB Swap, 8GB Disk (ZFS).
- **Features**: `nesting=1,keyctl=1`

## Ingress & Routing
- DNS: AdGuard Rewrite `butler.labs4it.dev` -> `192.168.10.110` (Traefik)
- Traefik: Protected by `authelia@file` (2FA) and `crowdsec@file`
