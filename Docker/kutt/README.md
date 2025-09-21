# 🔗 Kutt URL Shortener (Sanitised)

This directory packages a Docker-based deployment of [Kutt](https://github.com/thedevs-network/kutt) with all secrets replaced by placeholders so it is safe to publish.

## 📁 Structure

```
kutt/
├── Dockerfile                     # Production-ready Node build
├── docker-compose.yml             # Default stack (SQLite + Redis)
├── docker-compose.postgres.yml    # Optional Postgres bundle
├── docker-compose.mariadb.yml     # Optional MariaDB bundle
├── .env.example                   # Configuration template (copy to .env)
├── .gitignore / .dockerignore     # Keep secrets & artefacts out of git
├── custom/                        # Place custom themes/assets here
└── data/sqlite/                   # SQLite data directory (empty placeholder)
```

## 🚀 Quick Start (SQLite)

```bash
cp .env.example .env
# Fill in JWT_SECRET, DEFAULT_DOMAIN, Redis settings, etc.
docker compose up -d
```

The default compose file stores data under `data/sqlite/` and spins up a companion Redis instance for caching.

## 🗄️ Alternative Databases

Use the provided compose variants if you prefer Postgres or MariaDB:

```bash
# Postgres
cp docker-compose.postgres.yml docker-compose.override.yml
docker compose up -d

# MariaDB
cp docker-compose.mariadb.yml docker-compose.override.yml
docker compose up -d
```

Both variants expect credentials to be set in `.env` (see the template for the required variables).

## 🔐 Sanitisation Notes

- `.env` is gitignored; only the example template is committed.
- Domains, secrets, and passwords use documentation placeholders (e.g. `kutt.example.lab`, `REPLACE_ME_JWT`).
- No runtime data is committed—`data/sqlite/` contains a `.gitkeep` so you can persist your own database files.

## 🧩 Integrations

- Publish the service behind the `Docker/traefik` or `Docker/caddy` stacks for HTTPS and routing.
- Reuse the `DEFAULT_DOMAIN` and `REDIS_*` vars to keep URLs consistent across environments.

Happy shortening!
