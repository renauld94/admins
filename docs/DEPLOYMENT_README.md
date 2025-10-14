# 🚀 Fast Deployment Options for Portfolio

## Speed Comparison

| Method | Speed | Automation | Setup Time | Best For |
|--------|-------|------------|------------|----------|
| **Fast rsync** | 5-10s | Manual | 1 min | Quick updates |
| **GitHub Actions** | 15-30s | Auto | 10 min | CI/CD |
| **Docker** | 20-40s | Semi-auto | 5 min | Containerized |
| **Watch Mode** | Instant | Auto | 2 min | Development |
| **Webhook** | 10-20s | Auto | 15 min | Push-triggered |

## Quick Start

### ⚡ Fastest Option (5-10 seconds)

```bash
./fast_deploy.sh
```

### 🎯 Ultimate Choice Menu

```bash
./ultimate_deploy.sh
```

## Setup Instructions

### 1. Fast rsync Deployment

- ✅ Already configured
- ✅ Uses incremental sync
- ✅ Only transfers changed files

### 2. GitHub Actions (Automated)

1. Go to GitHub repo → Settings → Secrets
2. Add `PROXMOX_SSH_KEY` secret with your SSH private key
3. Push to main branch - auto-deploys!

### 3. Docker Deployment

```bash
cd portofio_simon_rennauld/simonrenauld.github.io
docker-compose up -d --build
```

### 4. Watch Mode (Development)

```bash
./ultimate_deploy.sh
# Choose option 4
```

### 5. Webhook Deployment (Advanced)

```bash
./webhook_deploy.sh
```

Then configure GitHub webhook to `http://your-server:9000`

## Performance Tips

- **rsync** is fastest for incremental changes
- **Docker** provides consistency and isolation
- **GitHub Actions** eliminates manual steps
- **Watch mode** is perfect for development

## Current Status

- ✅ Fast rsync: Ready to use
- ✅ GitHub Actions: Configured (needs SSH key secret)
- ✅ Docker: Ready to use
- ✅ Watch mode: Ready to use
- 🔄 Webhook: Needs webhook secret configuration

**Recommended**: Start with `./fast_deploy.sh` for immediate speed gains!
