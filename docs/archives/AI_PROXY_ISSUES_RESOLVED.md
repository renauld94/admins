# 🔧 AI Service Proxy Issues - RESOLVED

## 📋 Summary
Successfully resolved connectivity issues preventing external access to AI Conversation Partner service running on VM 10.0.0.110:8100.

## 🐛 Issues Identified

### 1. Firewall Blocking Port 8100
**Problem**: UFW firewall on VM 10.0.0.110 was not allowing traffic on port 8100 from Proxmox host.

**Symptoms**:
- Service worked on `localhost:8100` ✅
- Proxmox couldn't reach `10.0.0.110:8100` ❌
- Connection timeout errors in nginx logs

**Solution**:
```bash
sudo ufw allow from 10.0.0.0/24 to any port 8100 proto tcp comment 'AI Conversation Service'
```

**Verification**:
```bash
# From Proxmox:
curl http://10.0.0.110:8100/health
# Returns: {"status":"healthy", ...}
```

### 2. Nginx Path Routing Issue
**Problem**: Nginx regex location `location ~ ^/ai/(health|scenarios)` was **NOT** stripping the `/ai/` prefix when proxying.

**Symptoms**:
- Requests to `https://moodle.simondatalab.de/ai/health` 
- Were forwarded as `http://10.0.0.110:8100/ai/health` (wrong!)
- But service only has `/health` endpoint (no `/ai` prefix)
- Resulted in 404 Not Found

**Root Cause**: When using regex locations with `proxy_pass`, nginx only strips the matched portion if you include a URI in `proxy_pass`. With `proxy_pass http://10.0.0.110:8100;` (no trailing path), the full request path is forwarded.

**Solution**: Replace regex location with simple prefix location:

```nginx
# ❌ OLD (doesn't strip /ai/)
location ~ ^/ai/(health|scenarios) {
    proxy_pass http://10.0.0.110:8100;  # Forwards /ai/health -> /ai/health
}

# ✅ NEW (strips /ai/ correctly)
location /ai/ {
    proxy_pass http://10.0.0.110:8100/;  # Forwards /ai/health -> /health
}
```

## 🎯 Final Configuration

### VM 10.0.0.110 Firewall
```bash
# UFW rules
sudo ufw allow from 10.0.0.0/24 to any port 8100 proto tcp comment 'AI Conversation Service'
sudo ufw allow from 10.0.0.0/24 to any port 8088 proto tcp comment 'Analytics Service'
```

### Nginx Reverse Proxy (/etc/nginx/sites-enabled/moodle.simondatalab.de.conf)
```nginx
server {
    listen 443 ssl http2;
    server_name moodle.simondatalab.de;

    # AI WebSocket for conversation (strips /ai/ prefix)
    location /ai/ws/ {
        proxy_pass http://10.0.0.110:8100/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;
    }

    # AI REST API endpoints (strips /ai/ prefix)
    location /ai/ {
        proxy_pass http://10.0.0.110:8100/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # AI conversation interface HTML
    location = /ai/conversation-practice.html {
        alias /var/www/moodle-assets/conversation_practice.html;
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }
}
```

## ✅ Verification Tests

### 1. Health Check
```bash
curl -s https://moodle.simondatalab.de/ai/health | jq
```
**Result**:
```json
{
  "status": "healthy",
  "service": "ai-conversation",
  "ollama_available": true,
  "models_loaded": [
    "gemma2:9b",
    "mistral:7b-instruct",
    "qwen2.5:7b-instruct",
    "deepseek-coder:6.7b",
    "llama3.1:8b"
  ],
  "active_sessions": 0
}
```

### 2. Scenarios List
```bash
curl -s https://moodle.simondatalab.de/ai/scenarios | jq
```
**Result**:
```json
{
  "scenarios": [
    {
      "id": "coffee_shop",
      "name": "Coffee Shop Conversation",
      "vocabulary_count": 7
    },
    {
      "id": "greetings",
      "name": "Basic Greetings & Introductions",
      "vocabulary_count": 7
    },
    {
      "id": "business_meeting",
      "name": "Business Meeting",
      "vocabulary_count": 6
    },
    {
      "id": "shopping",
      "name": "Shopping at Market",
      "vocabulary_count": 7
    },
    {
      "id": "restaurant",
      "name": "Ordering at Restaurant",
      "vocabulary_count": 6
    }
  ]
}
```

### 3. Service Info
```bash
curl -s https://moodle.simondatalab.de/ai/ | jq
```
**Result**:
```json
{
  "service": "AI Conversation Partner",
  "version": "1.0",
  "status": "running",
  "scenarios": ["coffee_shop", "greetings", "business_meeting", "shopping", "restaurant"]
}
```

## 🔑 Key Learnings

### Nginx `proxy_pass` Behavior

1. **WITH trailing slash** = strips location prefix:
   ```nginx
   location /api/ {
       proxy_pass http://backend/;  # /api/test -> /test
   }
   ```

2. **WITHOUT trailing slash** = keeps full path:
   ```nginx
   location /api/ {
       proxy_pass http://backend;   # /api/test -> /api/test
   }
   ```

3. **Regex locations** don't automatically strip unless you explicitly use `rewrite` or include captured groups in the proxy_pass URI.

### Firewall Considerations
- Always check both UFW and iptables when debugging connectivity
- Verify with `ss -tulpn | grep <port>` that service is bound to `0.0.0.0` not `127.0.0.1`
- Test connectivity from the proxy host itself before testing external access

## 📚 Network Path

```
Browser
  ↓
Cloudflare CDN (HTTPS)
  ↓
Proxmox nginx 136.243.155.166:443
  ↓ (internal network)
VM 10.0.0.110:8100 - AI Conversation Service
  ↓
localhost:11434 - Ollama LLM Service
```

## 🎓 Next Steps

1. ✅ External API access working
2. 🔄 Upload conversation_practice.html to `/var/www/moodle-assets/`
3. 🔄 Test WebSocket connection from browser
4. 🔄 Embed iframe in Moodle Vietnamese course
5. 🔄 Deploy remaining AI services (ports 8101-8107)

---

**Date**: 2025-11-03  
**Status**: ✅ RESOLVED  
**Service**: AI Conversation Partner (port 8100)
