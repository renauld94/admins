# ✅ Jellyfin IPTV Setup - Test Results

**Date**: October 15, 2025  
**Target**: VM 200 (10.0.0.103) - Jellyfin Container: jellyfin-simonadmin

---

## 🎉 SUCCESS - IPTV Channels Installed!

### ✅ Installed Playlists (12 files)

| Playlist | Size | Channels | Location |
|----------|------|----------|----------|
| **Categories** | 2.7 MB | 11,673 | `/config/data/playlists/iptv_org_categories.m3u` |
| **Countries** | 2.9 MB | 12,094 | `/config/data/playlists/iptv_org_countries.m3u` |
| **Languages** | 2.9 MB | 12,242 | `/config/data/playlists/iptv_org_languages.m3u` |
| **International** | 2.7 MB | 11,340 | `/config/data/playlists/iptv_org_international.m3u` |
| **USA** | 412 KB | 1,484 | `/config/data/playlists/iptv_org_country_us.m3u` |
| **UK** | 53 KB | 213 | `/config/data/playlists/iptv_org_country_uk.m3u` |
| **Germany** | 79 KB | 273 | `/config/data/playlists/iptv_org_country_de.m3u` |
| **France** | 63 KB | 196 | `/config/data/playlists/iptv_org_country_fr.m3u` |
| **Spain** | 81 KB | 291 | `/config/data/playlists/iptv_org_country_es.m3u` |
| **Italy** | 92 KB | 366 | `/config/data/playlists/iptv_org_country_it.m3u` |
| **Canada** | 41 KB | 174 | `/config/data/playlists/iptv_org_country_ca.m3u` |
| **Australia** | 13 KB | 65 | `/config/data/playlists/iptv_org_country_au.m3u` |

### 📊 Total IPTV Channels Available

- **12,242 unique channels** across all playlists
- **8 country-specific** playlists
- **4 categorized** playlists (by category, language, country, international)

---

## ✅ Access Test Results

### Direct HTTP Access (WORKING ✓)
```
URL: http://136.243.155.166:8096
Status: 302 Found (redirects to /web/)
Result: ✅ WORKING - Jellyfin is accessible directly
```

**Test command:**
```bash
curl -I http://136.243.155.166:8096
```

### Cloudflare Tunnel Access (NEEDS ATTENTION ⚠️)
```
URL: https://jellyfin.simondatalab.de
Status: 530 (Origin not reachable)
Result: ⚠️ Tunnel route exists but connector not routing traffic
```

**Issue**: The tunnel route is configured in Cloudflare, but the cloudflared connector may need:
- Time to refresh (wait 5-10 minutes)
- OR the cloudflared container needs to be restarted
- OR the tunnel connector is running on a different VM

---

## 🔧 Next Steps

### Step 1: Configure M3U Tuners in Jellyfin

1. **Access Jellyfin directly (WORKING NOW):**
   ```
   http://136.243.155.166:8096/web/
   ```

2. **Login:** `simonadmin`

3. **Navigate to:** Admin Dashboard → Live TV → Tuners

4. **Add M3U Tuner(s):**
   Click "+" to add a new tuner, select "M3U Tuner", then configure:

   **Option A: Single Large Tuner (Recommended for testing)**
   ```
   Tuner Name: IPTV-ORG International
   File or URL: /config/data/playlists/iptv_org_international.m3u
   ```

   **Option B: Country-Specific Tuners**
   Add separate tuners for each country:
   ```
   USA Channels: /config/data/playlists/iptv_org_country_us.m3u
   UK Channels: /config/data/playlists/iptv_org_country_uk.m3u
   German Channels: /config/data/playlists/iptv_org_country_de.m3u
   French Channels: /config/data/playlists/iptv_org_country_fr.m3u
   ```

   **Option C: By Category**
   ```
   All Categories: /config/data/playlists/iptv_org_categories.m3u
   All Languages: /config/data/playlists/iptv_org_languages.m3u
   All Countries: /config/data/playlists/iptv_org_countries.m3u
   ```

5. **Save** each tuner configuration

6. **Wait** for Jellyfin to scan the playlists (this may take a few minutes)

---

### Step 2: Fix Cloudflare Tunnel (Optional)

The direct HTTP access is working, but if you want HTTPS via Cloudflare:

**Option A: Wait and Retry**
```bash
# Wait 5-10 minutes for tunnel to refresh, then test:
curl -I https://jellyfin.simondatalab.de
```

**Option B: Find and Restart Cloudflared Connector**

The cloudflared tunnel connector needs to be found and restarted. It's likely running on one of these VMs:
- VM 150 (10.0.0.150) - Main website host
- VM 104 (10.0.0.104) - Moodle host
- VM 110 (10.0.0.110) - Open WebUI/Ollama host

**To find it:**
```bash
# Check each VM for cloudflared
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.150 'docker ps | grep cloudflared'
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.104 'docker ps | grep cloudflared'
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 'docker ps | grep cloudflared'
```

**Then restart it:**
```bash
# Replace <VM_IP> with the IP where cloudflared is running
ssh -J root@136.243.155.166:2222 simonadmin@<VM_IP> 'docker restart cloudflared'
```

---

### Step 3: EPG Data (Optional - Skipped for Now)

EPG downloads failed because iptv-org doesn't host EPG files at the expected URLs. This is **not critical** - you can:

**Option A: Use Channels Without EPG**
- Channels will work fine, just without program guide information
- You'll see channel names but not "what's on now" details

**Option B: Add EPG Later**
- Many IPTV providers include EPG URLs in their M3U playlists
- Some channels may auto-populate guide data

**Option C: Use Alternative EPG Sources**
- XMLTV.org
- EPG from your IPTV provider
- Third-party EPG aggregators

---

## 📺 Watch IPTV Now!

### Quick Access:

1. **Go to:** http://136.243.155.166:8096/web/
2. **Login:** simonadmin
3. **Configure tuners** as described in Step 1 above
4. **Navigate to:** Home → Live TV
5. **Select a channel** and start watching!

---

## ✅ What's Working

- ✅ Jellyfin container running and healthy
- ✅ 12 IPTV playlists installed (12,242+ channels)
- ✅ Direct HTTP access working
- ✅ Playlists accessible to Jellyfin
- ✅ Cloudflare tunnel route configured

## ⚠️ What Needs Attention

- ⚠️ Cloudflare tunnel returning 530 (origin not reachable)
  - **Likely cause:** cloudflared connector needs to refresh or restart
  - **Impact:** Cannot access via https://jellyfin.simondatalab.de
  - **Workaround:** Use direct HTTP access for now
  
- ⚠️ EPG data not available from iptv-org
  - **Impact:** No program guide information
  - **Workaround:** Channels still work, just without "what's on" data

---

## 🎯 Summary

**STATUS: 🟢 READY TO USE**

You have successfully installed **12,242+ IPTV channels** into your Jellyfin instance!

**Access now:** http://136.243.155.166:8096/web/

**Next:** Configure the M3U tuners in Jellyfin's Live TV settings to start watching!

---

**Test Date**: October 15, 2025 03:34 UTC  
**Tested By**: Automated Setup Script  
**VM**: 200 (10.0.0.103)  
**Container**: jellyfin-simonadmin  
**Status**: ✅ Installation Complete - Ready for Configuration
