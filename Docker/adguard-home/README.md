# 🛡️ AdGuard Home (Sanitised Example)

This directory packages a production-tested AdGuard Home deployment with all sensitive values replaced by placeholders so you can adapt it safely.

## 📁 Structure

```
adguard-home/
├── docker-compose.yaml     # Container definition
├── README.md               # This documentation
├── conf/AdGuardHome.yaml   # Sample configuration (no secrets)
├── work/                   # Data directory (empty placeholder)
└── .gitignore              # Ignores runtime artefacts
```

## 🚀 Usage

1. Copy `conf/AdGuardHome.yaml` and adjust to your network (admin user, upstream DNS, etc.).
2. Optional: create `work/` subdirectories (`data/`, `logs/`) as needed.
3. Launch the stack:
   ```bash
   docker-compose up -d
   ```
4. Access the UI via `http://localhost:3000` (or behind Traefik/Caddy).

## 🔐 Sanitisation Notes

- The `password` field in the sample config contains a placeholder bcrypt hash (`$2a$10$example...`). Replace it with a hash generated via `htpasswd -nbB admin "yourpass"`.
- Upstream DNS servers use public resolvers (Google, Quad9) as safe defaults.
- TLS is disabled by default; enable it when fronting AdGuard with your own certificates or reverse proxy.

## 📊 Monitoring

The config keeps query logging enabled. Integrate with Prometheus or your log pipeline if required.

## 🧩 Integrations

- Combine with `../traefik` for HTTPS ingress.
- Feed metrics into `../monitor` stack using exporters.

Enjoy cleaner DNS without exposing any of your original environment details.
