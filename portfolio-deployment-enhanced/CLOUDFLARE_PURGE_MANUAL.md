# Manual Cloudflare Cache Purge Instructions

## Quick Purge (Recommended)

Since the API token has expired, use the Cloudflare dashboard:

### Option 1: Dashboard Purge (30 seconds)

1. Go to: https://dash.cloudflare.com/
2. Select domain: **simondatalab.de**
3. Navigate to: **Caching** → **Configuration**
4. Click: **Purge Everything**
5. Confirm the purge

### Option 2: API Purge (if you have token)

If you have a valid API token:

```bash
export CLOUDFLARE_API_TOKEN="your-token-here"

curl -X POST "https://api.cloudflare.com/client/v4/zones/8721a7620b0d4b0d29e926fda5525d23/purge_cache" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'
```

### Option 3: Selective Purge (faster, less disruptive)

Purge only the changed files:

```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/8721a7620b0d4b0d29e926fda5525d23/purge_cache" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "files": [
      "https://www.simondatalab.de/",
      "https://www.simondatalab.de/index.html"
    ]
  }'
```

## Verification After Purge

1. **Check the change is live:**
   ```bash
   curl -s https://www.simondatalab.de | grep -A2 "__ALLOW_NEURAL_AUTOLOAD__"
   ```
   
   Expected output:
   ```javascript
   window.__ALLOW_NEURAL_AUTOLOAD__ = false;
   ```

2. **Test in browser (hard refresh):**
   - Chrome/Edge: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
   - Firefox: `Ctrl+F5` (Windows/Linux) or `Cmd+Shift+R` (Mac)
   - Safari: `Cmd+Option+R`

3. **Verify via DevTools:**
   - Open browser DevTools (F12)
   - Console tab
   - Check for: `[three-loader] Auto-load disabled by __ALLOW_NEURAL_AUTOLOAD__ flag`

## Current Deployment State

- ✅ Origin Server (CT 150): Updated with `__ALLOW_NEURAL_AUTOLOAD__ = false`
- ⚠️ Cloudflare Edge: Still cached (pending purge)
- ⏱️ Propagation Time: ~5 minutes after purge

## Zone Information

- **Zone ID:** 8721a7620b0d4b0d29e926fda5525d23
- **Domain:** simondatalab.de
- **Wildcard:** *.simondatalab.de

## Getting a New API Token

If you need a new token:

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click: **Create Token**
3. Use template: **Edit zone DNS** or **Custom token**
4. Permissions needed:
   - Zone → Cache Purge → Purge
   - Zone → Zone → Read
5. Zone Resources:
   - Include → Specific zone → simondatalab.de
6. Copy the token (shown only once!)
7. Store securely:
   ```bash
   echo "YOUR_TOKEN" > ~/.cloudflare_api_token
   chmod 600 ~/.cloudflare_api_token
   ```

## Troubleshooting

### Cache still serving old version?
- Wait 5 minutes after purge
- Try incognito/private browsing
- Check if origin is correct:
  ```bash
  curl -H "Host: www.simondatalab.de" http://136.243.155.166 | grep "__ALLOW_NEURAL_AUTOLOAD__"
  ```

### Purge failed?
- Verify token permissions include "Cache Purge"
- Check token expiration date
- Ensure zone ID is correct

### Still seeing autoload = true?
- Confirm deployment to CT 150:
  ```bash
  ssh -p 2222 root@136.243.155.166 "pct exec 150 -- grep '__ALLOW_NEURAL_AUTOLOAD__' /var/www/html/index.html"
  ```

---

**Last Updated:** November 4, 2025  
**Status:** Awaiting cache purge
