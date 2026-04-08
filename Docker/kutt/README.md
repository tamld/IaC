# 🔗 Kutt — Self-Hosted URL Shortener

Modern, open-source URL shortener with analytics. Supports PostgreSQL and MariaDB backends.

## Compose Variants

| File | Database |
|------|----------|
| `docker-compose.yml` | Default (PostgreSQL) |
| `docker-compose.postgres.yml` | Explicit PostgreSQL config |
| `docker-compose.mariadb.yml` | MariaDB backend |

## Quick Start

```bash
cp docker-compose.yml docker-compose.override.yml  # optional
$EDITOR .env   # Set SITE_NAME, DEFAULT_DOMAIN, JWT_SECRET, DB credentials
docker compose up -d
```

## Notes

- Admin panel at `/admin` (requires `ADMIN_EMAILS` env var)
- Redis required for rate limiting and caching
- Set `DISALLOW_REGISTRATION=true` to prevent public sign-ups
