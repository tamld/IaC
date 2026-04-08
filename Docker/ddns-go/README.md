# 🌐 DDNS-Go — Dynamic DNS Updater

Automatically updates DNS records when your public IP changes. Supports Cloudflare, Aliyun, Namecheap, GoDaddy, and more.

## Quick Start

```bash
cp docker-compose.yml docker-compose.override.yml  # optional
$EDITOR docker-compose.yml   # Set DDNS_GO_* env vars
docker compose up -d
# Admin UI at http://<host>:9876
```

## Supported Providers

Cloudflare · Aliyun · Namecheap · GoDaddy · DNSPod · HE.net · Huawei Cloud · and more

## Notes

- Configure via web UI on first run (port `9876`)
- Checks IP every 5 minutes by default
- Supports IPv4 and IPv6
