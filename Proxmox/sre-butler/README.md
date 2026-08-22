# Proxmox Autonomous SRE Butler (`SRE_BUTLER`)

## Deployment Specifications
- **ID**: `SRE_BUTLER`
- **Hostname**: `svc-butler`
- **IP**: `192.168.1.121/24`
- **Gateway**: `192.168.1.1`
- **Resources**: 2 Cores, 256MB RAM, 256MB Swap, 8GB Disk (ZFS).
- **Features**: `nesting=1,keyctl=1`

## Ingress & Routing
- DNS: AdGuard Rewrite `butler.example.com` -> `192.168.1.110` (Traefik)
- Traefik: Protected by `authelia@file` (2FA) and `crowdsec@file`
