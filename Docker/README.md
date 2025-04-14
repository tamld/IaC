# 🐳 Docker Infrastructure as Code

This directory contains battle-tested Docker configurations, compose files, and templates sourced from real-world deployments. Consider these as "boilerplate Docker" setups that you can adapt for your own environments.

## 📚 Table of Contents

| Service | Description |
|---------|-------------|
| [🛡️ AdGuard Home](./adguard-home/) | DNS filtering and ad blocking solution |
| [🔄 DDNS-Go](./ddns-go/) | Dynamic DNS update client |
| [📊 Monitoring](./monitor/) | Prometheus, Grafana, and alerting stack |
| [🔄 Traefik](./traefik/) | Modern reverse proxy and load balancer |
| [🔐 Teleport](./teleport/) | Secure SSH and Kubernetes access |
| [🔒 Vaultwarden](./vaultwarden/) | Self-hosted password manager (Bitwarden) |
| [📝 Caddy](./caddy/) | HTTP/2 web server with automatic HTTPS |

## 🔧 Implementation Guide

Each service directory follows a consistent structure designed for learning and adaptation:

```
service-name/
├── docker-compose.yml       # Container orchestration template
├── .env                     # Sample environment variables (safe for sharing)
├── .env.local.example       # Template for local environment variables (DO NOT COMMIT)
├── config/                  # Configuration files with example values
└── README.md                # Service documentation and implementation notes
```

### Environment Files Strategy

- `.env` - Contains example/dummy values (safe to commit)
- `.env.local` - Contains your actual values (add to .gitignore)

## 🚀 Usage Instructions

1. Copy the service directory you need
2. Create your `.env.local` file from the example:
   ```bash
   cp .env.local.example .env.local
   ```
3. Edit the `.env.local` file with your actual values
4. Deploy with docker-compose:
   ```bash
   docker-compose --env-file .env.local up -d
   ```

## 📋 Best Practices

1. **Environment Separation**: Keep example values in `.env` and real values in `.env.local`
2. **Version Control**: Add `.env.local` to `.gitignore` to prevent accidental commits
3. **Documentation**: Each service includes detailed documentation and notes
4. **Configuration as Code**: Store all configuration files in version control (with sensitive data masked)
5. **Portability**: All services are designed to work across different environments

## 🛠️ Service-Specific Notes

### 🔄 Traefik

- Modern, production-ready reverse proxy
- Automatic HTTPS with Let's Encrypt
- Docker provider for automatic service discovery

### 📊 Monitoring Stack

- Prometheus for metrics collection
- Grafana for visualization
- Alertmanager for notifications
- Various exporters for system and service monitoring

### 🔐 Security Services

- AdGuard Home for DNS-level filtering
- Vaultwarden for secure password management
- Teleport for secure SSH access

## 📝 Contributing 

When adding new services or updating existing ones:

1. Always sanitize sensitive information
2. Include comprehensive documentation
3. Follow the established directory structure
4. Provide example configuration files
5. Separate sensitive values into `.env.local.example`