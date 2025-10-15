# 🎬 Jellyfin IPTV Setup - Complete Guide

## 📋 Overview

This guide covers the complete setup of Jellyfin with IPTV channels from the `iptv-org/awesome-iptv` repository on VM 200.

## 🎯 Current Status

### ✅ Infrastructure Ready
- **VM 200 IP**: 10.0.0.103
- **Jellyfin Container**: jellyfin-simonadmin (running, healthy)
- **Port**: 8096 (exposed to host)
- **Direct Access**: http://136.243.155.166:8096/web/
- **DNS Record**: jellyfin.simondatalab.de ✓ (already exists)

### 🔄 Cloudflare Tunnel Configuration

#### Current Routes (1-9)
| # | Hostname | Service |
|---|----------|---------|
| 1 | simondatalab.de | http://10.0.0.150:80 |
| 2 | www.simondatalab.de | http://10.0.0.150:80 |
| 3 | moodle.simondatalab.de | http://10.0.0.104:80 |
| 4 | grafana.simondatalab.de | http://10.0.0.104:3000 |
| 5 | openwebui.simondatalab.de | http://10.0.0.110:3001 |
| 6 | geoneuralviz.simondatalab.de | http://10.0.0.106:8080 |
| 7 | booklore.simondatalab.de | http://10.0.0.103:6060 |
| 8 | ollama.simondatalab.de | http://10.0.0.110:11434 |
| 9 | mlflow.simondatalab.de | http://10.0.0.110:5000 |

#### ⚡ Route to Add (Route #10)
| # | Hostname | Service |
|---|----------|---------|
| 10 | **jellyfin.simondatalab.de** | **http://10.0.0.103:8096** |

## 🚀 Setup Instructions

### Step 1: Add Cloudflare Tunnel Route

#### ⚠️ Important: DNS Record Already Exists!
The error you encountered is because `jellyfin.simondatalab.de` DNS record already exists (pointing to Cloudflare's proxy IPs). This is **GOOD** - you just need to add the tunnel route.

#### Solution: Add Route Without Creating DNS Record

**Via Cloudflare Dashboard:**

1. **Navigate to**: https://one.dash.cloudflare.com/
2. **Go to**: Zero Trust → Access → Tunnels
3. **Select**: `simondatalab-tunnel`
4. **Click**: "Add a public hostname" (or "Configure" → "Public Hostname" → "Add a public hostname")

5. **Configure the route:**
   ```
   Subdomain: jellyfin
   Domain: simondatalab.de
   Path: (leave empty or use *)
   
   Service:
     Type: HTTP
     URL: 10.0.0.103:8096
   
   Additional settings:
     - HTTP Host Header: (leave default)
     - No TLS Verify: OFF (recommended for security)
   ```

6. **Important**: When you see the DNS warning, you should have an option to:
   - **Use existing DNS record** ✓ (select this)
   - OR **Ignore the DNS record creation**

7. **Click**: "Save hostname"

#### Alternative Subdomains (if conflicts persist)
If you continue having issues, try these alternatives:
- `tv.simondatalab.de`
- `jf.simondatalab.de`
- `media.simondatalab.de`
- `stream.simondatalab.de`

### Step 2: Verify Tunnel Route

After adding the route, verify it's working:

```bash
# Check DNS resolution
nslookup jellyfin.simondatalab.de

# Test HTTPS connection
curl -I https://jellyfin.simondatalab.de

# Check if Jellyfin web interface responds
curl -L https://jellyfin.simondatalab.de/web/ | head -n 20
```

Expected DNS result:
```
Name:   jellyfin.simondatalab.de
Address: 172.67.178.240
Address: 104.21.31.178
```
(These are Cloudflare proxy IPs - this is correct!)

### Step 3: Install IPTV Channels

Once the tunnel route is working, install IPTV channels from iptv-org:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./setup_jellyfin_iptv.sh
```

This script will:
1. ✅ Download M3U playlists from iptv-org/awesome-iptv
2. ✅ Upload to VM 200
3. ✅ Install into Jellyfin container
4. ✅ Set proper permissions
5. ✅ Verify installation

#### IPTV Sources Included:
- **Main playlists**: International, by category, by language, by country
- **Country-specific**: US, UK, DE, FR, ES, IT, CA, AU
- **Total channels**: 1000+ from various countries

### Step 4: Configure IPTV in Jellyfin

#### Access Jellyfin:
- **Via Tunnel**: https://jellyfin.simondatalab.de/web/
- **Direct IP**: http://136.243.155.166:8096/web/
- **Login**: simonadmin

#### Add M3U Tuners:

1. **Navigate**: Admin Dashboard → Live TV
2. **Click**: "+" next to "Tuners" or "Add Tuner"
3. **Select**: "M3U Tuner"
4. **Configure**:
   - **Tuner Name**: "IPTV-ORG International" (or any descriptive name)
   - **M3U URL**: `/config/data/playlists/iptv_org_international.m3u`
   - **OR** use file path for each playlist:
     - `/config/data/playlists/iptv_org_categories.m3u`
     - `/config/data/playlists/iptv_org_languages.m3u`
     - `/config/data/playlists/iptv_org_countries.m3u`
     - `/config/data/playlists/iptv_org_country_us.m3u`
     - `/config/data/playlists/iptv_org_country_uk.m3u`
     - etc.
5. **Click**: "Save"

**Repeat for each playlist** or combine them into a single tuner.

### Step 5: Add EPG (Electronic Program Guide)

For program guide data, run the EPG setup:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./add_iptv_org_epg.sh
```

Then in Jellyfin:
1. **Navigate**: Admin Dashboard → Live TV
2. **Click**: "+" next to "TV Guide Data Providers"
3. **Select**: "XMLTV"
4. **Configure**:
   - **File path**: `/config/iptv_org_epg_*.xml`
   - Or select specific files:
     - `/config/iptv_org_epg_us.xml`
     - `/config/iptv_org_epg_uk.xml`
     - etc.
5. **Click**: "Save"

### Step 6: Refresh Guide Data

1. **Navigate**: Admin Dashboard → Scheduled Tasks
2. **Find**: "Refresh Guide"
3. **Click**: Run task manually
4. **Wait**: 5-10 minutes for guide data to populate

## 🎯 Access Points

### Jellyfin Access:
- **Public (via Cloudflare)**: https://jellyfin.simondatalab.de
- **Direct IP**: http://136.243.155.166:8096
- **Local (from VM network)**: http://10.0.0.103:8096

### Watch Live TV:
1. **Access Jellyfin** (any method above)
2. **Navigate**: Home → Live TV
3. **Select**: Channel to watch
4. **Enjoy**: Your IPTV channels!

## 🔧 Troubleshooting

### Cloudflare Tunnel Issues

**DNS Record Error:**
```
Error: An A, AAAA, or CNAME record with that host already exists.
```
**Solution**: Use existing DNS record when adding tunnel route (see Step 1)

**Verify tunnel is running:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps | grep cloudflared'
```

### Jellyfin Container Issues

**Check container status:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps | grep jellyfin'
```

**Restart container:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'
```

**Check logs:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs -f jellyfin-simonadmin'
```

### IPTV Channel Issues

**Verify playlists exist:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 \
  'docker exec jellyfin-simonadmin ls -lh /config/data/playlists/'
```

**Check EPG files:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 \
  'docker exec jellyfin-simonadmin ls -lh /config/iptv_org_epg_*.xml'
```

**Manually refresh guide:**
```bash
# In Jellyfin web UI:
# Admin Dashboard → Scheduled Tasks → Refresh Guide → Run Now
```

### Channels Not Playing

**Common causes:**
1. **Stream URL dead**: IPTV streams frequently go offline
2. **Geo-blocking**: Some streams are region-restricted
3. **Format issues**: Jellyfin may not support certain codecs
4. **Network issues**: Check VM internet connectivity

**Test stream manually:**
```bash
# Test a stream URL directly
mpv "http://stream-url-here.m3u8"
# or
ffplay "http://stream-url-here.m3u8"
```

## 📊 Expected Results

### After Complete Setup:

✅ **Cloudflare Tunnel**: https://jellyfin.simondatalab.de accessible  
✅ **IPTV Channels**: 1000+ channels available  
✅ **EPG Data**: Program guide for supported channels  
✅ **Live TV**: Playable through Jellyfin web interface  
✅ **Mobile Access**: Available via Jellyfin apps (iOS/Android)  

## 📱 Mobile Access

### Jellyfin Apps:
- **iOS**: Download "Jellyfin" from App Store
- **Android**: Download "Jellyfin" from Google Play
- **Configuration**:
  - Server: `https://jellyfin.simondatalab.de`
  - Username: `simonadmin`
  - Password: [your password]

## 🔐 Security Recommendations

### Current Setup:
- ✅ HTTPS via Cloudflare (secure)
- ✅ Cloudflare WAF protection
- ✅ Container isolation
- ⚠️ Consider adding Cloudflare Access for authentication

### Optional: Add Cloudflare Access Policy

To restrict access to Jellyfin:
1. **Navigate**: Cloudflare Zero Trust → Access → Applications
2. **Create**: New application
3. **Configure**: 
   - Domain: `jellyfin.simondatalab.de`
   - Policy: Email authentication, IP range, etc.
4. **Save**: Users will need to authenticate before accessing

## 📚 Resources

### Scripts Created:
- `/home/simon/Learning-Management-System-Academy/scripts/setup_jellyfin_iptv.sh` - IPTV channel installer
- `/home/simon/Learning-Management-System-Academy/scripts/add_iptv_org_epg.sh` - EPG data installer
- `/home/simon/Learning-Management-System-Academy/scripts/add_jellyfin_tunnel_route.sh` - Tunnel setup guide

### External Resources:
- **IPTV-ORG**: https://github.com/iptv-org/iptv
- **Awesome IPTV**: https://github.com/iptv-org/awesome-iptv
- **Jellyfin Docs**: https://jellyfin.org/docs/
- **Cloudflare Tunnels**: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/

## 🎉 Success Checklist

- [ ] Cloudflare tunnel route added for jellyfin.simondatalab.de
- [ ] Can access https://jellyfin.simondatalab.de
- [ ] IPTV playlists installed in Jellyfin container
- [ ] M3U tuners added in Jellyfin
- [ ] EPG data installed and configured
- [ ] Guide data refreshed successfully
- [ ] Can see channels in Live TV section
- [ ] Can play at least one channel successfully
- [ ] Mobile apps configured (optional)
- [ ] Security policies applied (optional)

---

**🎯 VM**: 200 (10.0.0.103)  
**🔧 Container**: jellyfin-simonadmin  
**🌐 URL**: https://jellyfin.simondatalab.de  
**👤 User**: simonadmin  
**📺 Purpose**: Media streaming with Live TV/IPTV  
**📅 Setup Date**: October 15, 2025
