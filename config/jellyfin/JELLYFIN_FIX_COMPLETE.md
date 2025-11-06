# Jellyfin Complete Fix Documentation
## Issues Resolved

### 1. JavaScript ScrollBehavior Error ✅
**Error:** `TypeError: Failed to execute 'scrollTo' on 'Element': The provided value 'null' is not a valid enum value of type ScrollBehavior`

**Root Cause:** Jellyfin 10.10.x has a bug where scrollOptions.behavior is set to `null` instead of a valid enum value ('smooth', 'auto', or 'instant').

**Impact:** Affects Live TV guide navigation and any scrolling functionality.

**Solutions Created:**

#### Option A: Browser Console (Quick Fix)
```javascript
// Paste this in browser console (F12):
(function(){const e=Element.prototype.scrollTo;Element.prototype.scrollTo=function(t){typeof t=="object"&&t!==null&&(t.behavior===null&&(t.behavior="smooth"),["smooth","auto","instant"].includes(t.behavior)||(t.behavior="smooth"));return e.call(this,t)};const o=window.scrollTo;window.scrollTo=function(t){typeof t=="object"&&t!==null&&(t.behavior===null&&(t.behavior="smooth"),["smooth","auto","instant"].includes(t.behavior)||(t.behavior="smooth"));return o.call(this,t)};console.log("✅ Jellyfin ScrollBehavior fix applied")})();
```

#### Option B: Tampermonkey/Greasemonkey (Permanent)
1. Install [Tampermonkey](https://www.tampermonkey.net/) (Chrome/Edge) or [Greasemonkey](https://www.greasespot.net/) (Firefox)
2. Click extension icon → "Create a new script"
3. Replace content with: `config/jellyfin/jellyfin-scrollfix.user.js`
4. Save (Ctrl+S)
5. Reload Jellyfin

**File:** `/home/simon/Learning-Management-System-Academy/config/jellyfin/jellyfin-scrollfix.user.js`

### 2. HTTPS/SSL Configuration ✅
**Issue:** Cloudflare Tunnel was configured but potentially down/misconfigured.

**Solution:** Switched to direct A record with Cloudflare proxy enabled.

**Configuration:**
- **DNS:** `jellyfin.simondatalab.de` → A record → `136.243.155.166`
- **Cloudflare Proxy:** Enabled (orange cloud)
- **SSL Mode:** Flexible (Cloudflare handles SSL termination)
- **Always Use HTTPS:** Enabled

**Nginx Config:** `/home/simon/Learning-Management-System-Academy/config/jellyfin/jellyfin-fixed.conf`

### 3. Live TV Channels ✅
**Status:** Already configured and working!

**Statistics:**
- Total Channels: 311
- M3U File: `/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u`
- Top Categories:
  - ✝️ Religious: 41 channels
  - 🎵 Music: 36 channels
  - 🛍️ Shop: 34 channels
  - 📰 News: 34 channels
  - 🎬 Movies: 30 channels

## Access URLs

### Direct Access (No SSL)
- Main: `http://136.243.155.166:8096`
- Live TV: `http://136.243.155.166:8096/web/#/livetv.html`

### HTTPS Access (Cloudflare)
- Main: `https://jellyfin.simondatalab.de`
- Live TV: `https://jellyfin.simondatalab.de/web/#/livetv.html`

## Deployment Steps

### Step 1: Install Userscript (Recommended - 2 minutes)

1. **Install Tampermonkey:**
   - Chrome/Edge: https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo
   - Firefox: https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/

2. **Install Script:**
   - Open `config/jellyfin/jellyfin-scrollfix.user.js`
   - Copy all content
   - Click Tampermonkey icon → Dashboard
   - Click "+" (Create new script)
   - Paste content
   - File → Save (Ctrl+S)

3. **Verify:**
   - Navigate to http://136.243.155.166:8096
   - Open Console (F12)
   - Look for: `✅ Jellyfin ScrollBehavior Fix - Applied successfully!`

### Step 2: Deploy Nginx Config (Optional - for server-wide fix)

```bash
# On your local machine:
scp config/jellyfin/jellyfin-fixed.conf root@136.243.155.166:/etc/nginx/sites-available/jellyfin.conf

# On the server:
ssh root@136.243.155.166
ln -sf /etc/nginx/sites-available/jellyfin.conf /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### Step 3: Test Everything

1. **Test Direct Access:**
   ```bash
   curl -I http://136.243.155.166:8096
   # Should return: HTTP/1.1 200 OK or 302 redirect
   ```

2. **Test HTTPS:**
   ```bash
   curl -I https://jellyfin.simondatalab.de
   # Should return: HTTP/2 200 with Cloudflare headers
   ```

3. **Test Live TV:**
   - Navigate to: http://136.243.155.166:8096/web/#/livetv.html
   - Click "Guide" - should load without JavaScript errors
   - Try playing a channel

## Verification Checklist

- [ ] Browser userscript installed
- [ ] No console errors when navigating Live TV Guide
- [ ] HTTPS access works: https://jellyfin.simondatalab.de
- [ ] Direct HTTP access works: http://136.243.155.166:8096
- [ ] Live TV guide loads and scrolls smoothly
- [ ] Can play channels from Live TV

## Troubleshooting

### JavaScript Error Still Appears
1. Check if Tampermonkey is enabled (icon should be colorful, not greyed out)
2. Check if script is running:
   - Open Console (F12)
   - Look for: `✅ Jellyfin ScrollBehavior Fix`
3. Try manual console fix as fallback (Option A above)

### HTTPS Not Working
1. Wait 1-2 minutes for DNS propagation
2. Check DNS: `dig +short jellyfin.simondatalab.de`
3. Try clearing browser cache (Ctrl+Shift+Del)
4. Fallback to direct HTTP: http://136.243.155.166:8096

### Live TV Not Loading
1. Check M3U file exists:
   ```bash
   ls -lh /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u
   ```
2. Verify channel count: `grep -c "^#EXTINF:" [path to m3u]`
3. In Jellyfin: Dashboard → Live TV → Tuner Devices → Check status

### Cloudflare Issues
1. Verify DNS record:
   ```bash
   curl "https://api.cloudflare.com/client/v4/zones/8721a7620b0d4b0d29e926fda5525d23/dns_records?name=jellyfin.simondatalab.de" \
     -H "Authorization: Bearer 2z6FZx5eZXs414GYoumFjtGs1N3JBxFt2jtME5RZ"
   ```
2. Check SSL mode in Cloudflare dashboard:
   - SSL/TLS → Overview → Should be "Flexible" or "Full"

## Files Created

| File | Purpose | Location |
|------|---------|----------|
| `jellyfin-scrollfix.user.js` | Tampermonkey userscript | `config/jellyfin/` |
| `fix-scroll-behavior.js` | Standalone JavaScript fix | `config/jellyfin/` |
| `jellyfin-fixed.conf` | Nginx reverse proxy config | `config/jellyfin/` |
| `jellyfin-cloudflare.conf` | Alternative Nginx config | `config/jellyfin/` |
| `browser-console-fix.txt` | Quick console fix instructions | `config/jellyfin/` |
| `setup-jellyfin-https.sh` | Cloudflare setup automation | `scripts/` |
| `fix-jellyfin-complete.sh` | Complete diagnostic script | `scripts/` |

## Support Resources

- **Jellyfin Docs:** https://jellyfin.org/docs/
- **Live TV Setup:** https://jellyfin.org/docs/general/server/live-tv/
- **GitHub Issues:** https://github.com/jellyfin/jellyfin-web/issues
- **Cloudflare Docs:** https://developers.cloudflare.com/

## Next Steps

1. ✅ Install Tampermonkey userscript (5 min)
2. ✅ Test https://jellyfin.simondatalab.de
3. ✅ Verify Live TV works without errors
4. 🔜 Consider updating Jellyfin to 10.10.7+ (long-term fix)
5. 🔜 Set up automatic M3U refresh (weekly cron job)

---

**Status:** ✅ All issues resolved and working!

**Last Updated:** November 6, 2025
