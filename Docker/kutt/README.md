<div align="center">
  <img src="https://raw.githubusercontent.com/thedevs-network/kutt/develop/public/images/logo.png" width="80" />
  
  # Kutt
  **Modern & Open Source URL Shortener**
  
  [![Docker Pulls](https://img.shields.io/docker/pulls/kutt/kutt)](https://hub.docker.com/r/kutt/kutt)
</div>

---

## 🔗 What is Kutt?

Kutt is a modern URL shortener with support for custom domains. It provides a beautiful interface to shorten URLs, manage your links, and view highly detailed click statistics seamlessly.

### ✨ Key Features
- **Custom Domains:** Host it on a short vanity domain (like `s.co`).
- **Detailed Analytics:** Track clicks by country, browser, OS, and referrers.
- **RESTful API:** Build integrations allowing your applications to dynamically generate short links.
- **Link Management:** Password-protected links, Expiration dates, and link descriptions.

---

## ⚙️ Architecture & Compose Configuration

This stack packages the Next.js/Node frontend server alongside a Redis container used for caching short-link resolutions at incredibly high speeds. The primary database specified here is SQLite, which minimizes memory overhead for single-user deployments.

### Port Bindings
- `3000:3000` - The main Web API and routing frontend.

### Environment Requirements
- `DEFAULT_DOMAIN`: The root URL of your instance (e.g., `links.myname.com`).
- `JWT_SECRET`: A secure random string used to authenticate sessions.
- `REDIS_PORT`: Must match the exposed port on the Redis container (usually `6379`).

### Persistent Volumes
- `./data/sqlite:/var/lib/kutt` -> Stores all your URLs and analytics data.
- `./custom:/kutt/custom` -> An optional folder where you can place custom CSS or UI overrides.

---

## 🚀 Getting Started

### 1. Configure the Environment
Create a `.env` file containing the core authentication and domain parameters:
```env
REDIS_PORT=6379
DEFAULT_DOMAIN=links.example.com
JWT_SECRET=super_secure_randomly_generated_string_32_chars
CORS_ENABLED=true
```

### 2. Build and Start
*Note: This specific `docker-compose.yml` instructs docker to `build: .` rather than pulling a public image. This requires the Kutt source code tree to be present in this directory to build the NodeJS application.*
```bash
docker compose up -d --build
```

### 3. Usage
Navigate to `http://<your-server-ip>:3000`. 
Since it's your own instance, you can sign up to create your first admin account. Once logged in, simply paste long, unwieldy URLs into the main dashboard and click "Shorten".
