# Jellyfin Awesome Features Guide
## 🚀 What Makes Your Jellyfin Awesome

### 1. ✅ Automatic Channel Health Monitoring

**What it does:**
- Tests all 311 Live TV channels daily
- Removes dead/broken channels automatically
- Generates beautiful HTML health reports
- Maintains backups of M3U playlists
- Alerts if channel count drops critically

**Files:**
- Agent: `scripts/jellyfin-channel-monitor.py`
- Reports: `reports/jellyfin/channel-health-*.html`
- Backups: `alternative_m3u_sources/backups/`

**Usage:**
```bash
# Test channels (no changes)
python3 scripts/jellyfin-channel-monitor.py --dry-run

# Clean dead channels
python3 scripts/jellyfin-channel-monitor.py

# With custom settings
python3 scripts/jellyfin-channel-monitor.py --workers 30 --timeout 15
```

**Automation:**
- Runs daily at 3:00 AM (systemd timer or cron)
- Logs to `/var/log/jellyfin-monitor/channel-monitor.log`

---

### 2. 🎨 Fixed JavaScript ScrollBehavior Bug

**What it fixes:**
- "Failed to execute 'scrollTo'" error in Live TV guide
- Smooth navigation in EPG (Electronic Program Guide)
- No more console errors when browsing channels

**Installation:**
- Tampermonkey userscript: `config/jellyfin/jellyfin-scrollfix.user.js`
- Applies automatically on page load
- Works on both HTTP and HTTPS

---

### 3. 🔒 HTTPS with Cloudflare SSL

**What you get:**
- Secure HTTPS access: https://jellyfin.simondatalab.de
- Cloudflare CDN acceleration
- DDoS protection
- SSL certificate managed by Cloudflare (no Let's Encrypt hassle)

**Configuration:**
- DNS: jellyfin.simondatalab.de → 136.243.155.166 (proxied)
- SSL Mode: Flexible
- Always HTTPS: Enabled

---

### 4. 📊 Beautiful Health Reports

**Features:**
- HTML reports with dark theme matching your site
- Statistics by category
- Success rates and trends
- List of removed channels with error details
- Mobile-responsive design

**View Reports:**
```bash
# Open latest report
xdg-open reports/jellyfin/channel-health-*.html

# Or via web
# Copy to portfolio: 
cp reports/jellyfin/channel-health-*.html portfolio-deployment-enhanced/jellyfin-status.html
```

---

### 5. 🔄 Auto-Update Channels from IPTV-Org

**What it does:**
- Fetches latest channels from IPTV-Org database
- Merges with existing channels
- Tests all new channels before adding
- Updates M3U automatically

**Usage:**
```bash
./scripts/update-jellyfin-channels.sh
```

---

### 6. ⚡ Quick Command Shortcuts

**Convenient commands:**
```bash
# Test all channels
jellyfin test

# Remove dead channels
jellyfin clean

# Fetch new channels
jellyfin update

# Show status
jellyfin status

# Open latest report
jellyfin report
```

*(Or use `./scripts/jellyfin-commands.sh [command]` if not installed system-wide)*

---

## 🎯 Additional Recommendations

### 1. Hardware Transcoding (GPU Acceleration)

**For Intel/AMD GPU:**
```bash
# On the VM running Jellyfin
# Add to docker-compose.yml or LXC config
devices:
  - /dev/dri:/dev/dri  # Intel/AMD GPU

# In Jellyfin Dashboard:
# Settings → Playback → Hardware Acceleration
# Select: Video Acceleration API (VAAPI)
```

**Benefits:**
- 10x faster transcoding
- Lower CPU usage
- Support more concurrent streams
- Better quality at lower bitrates

---

### 2. Jellyfin Plugins to Install

**Via Dashboard → Plugins → Catalog:**

1. **TMDb** (The Movie Database)
   - Better metadata for movies/shows
   - High-quality posters and artwork
   
2. **Trakt**
   - Track what you watch
   - Sync across devices
   - Discover recommendations

3. **Kodi Sync Queue**
   - Sync with Kodi clients
   - Real-time library updates

4. **Reports**
   - Advanced usage statistics
   - User activity tracking

5. **Webhook**
   - Integrate with Discord/Slack
   - Notify on new content
   - Monitor playback events

---

### 3. EPG (Electronic Program Guide) Enhancement

**Add EPG data for Live TV:**

```bash
# Download EPG XML
wget https://iptv-org.github.io/epg/guides/en.xml -O /var/lib/jellyfin/epg/guide.xml

# In Jellyfin:
# Dashboard → Live TV → Guide Data Providers
# Add → XMLTV
# Path: /var/lib/jellyfin/epg/guide.xml
```

**Auto-update EPG:**
```cron
# Add to crontab
0 4 * * * wget -q https://iptv-org.github.io/epg/guides/en.xml -O /var/lib/jellyfin/epg/guide.xml
```

---

### 4. Intro/Credits Detection

**Skip intros automatically:**

Install **Intro Skipper** plugin:
```bash
# Dashboard → Plugins → Catalog
# Search: "Intro Skipper"
# Install and restart Jellyfin
```

**Configure:**
- Analyzes audio fingerprints
- Detects intro/outro patterns
- Shows "Skip Intro" button
- Can auto-skip for seamless watching

---

### 5. Mobile Apps

**Official Apps:**
- **iOS:** Jellyfin from App Store
- **Android:** Jellyfin from Google Play or F-Droid
- **Android TV:** Jellyfin TV
- **Roku:** Jellyfin Channel

**Configure:**
- Server: https://jellyfin.simondatalab.de
- Works with your fixed SSL setup
- Syncs watch progress across devices

---

### 6. Reverse Proxy Optimizations

**Nginx enhancements (already in config):**
- ✅ WebSocket support for Live TV
- ✅ Large file uploads (20GB)
- ✅ Long timeouts for streaming
- ✅ Cloudflare IP trust
- ✅ Security headers

**Additional:**
```nginx
# Add to jellyfin-fixed.conf
# Enable caching for static assets
location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
    expires 7d;
    add_header Cache-Control "public, immutable";
}
```

---

### 7. Monitoring & Alerts

**Setup Prometheus + Grafana:**

```bash
# Jellyfin Prometheus exporter
# Dashboard → Plugins → Catalog → Prometheus Exporter

# Then scrape in Prometheus:
scrape_configs:
  - job_name: 'jellyfin'
    static_configs:
      - targets: ['10.0.0.103:8096']
```

**Metrics tracked:**
- Active streams
- Transcoding sessions
- Library sizes
- User activity
- System resources

---

### 8. Automated Backups

**Backup script:**
```bash
#!/bin/bash
# Backup Jellyfin config and database

BACKUP_DIR="/backups/jellyfin"
DATE=$(date +%Y%m%d)

# Backup config
tar -czf "$BACKUP_DIR/jellyfin-config-$DATE.tar.gz" \
  /var/lib/jellyfin/config \
  /var/lib/jellyfin/data

# Backup M3U
cp /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u \
  "$BACKUP_DIR/m3u-$DATE.m3u"

# Keep last 7 days
find "$BACKUP_DIR" -name "jellyfin-*" -mtime +7 -delete
```

**Cron:**
```cron
0 2 * * * /path/to/backup-jellyfin.sh
```

---

### 9. Performance Tuning

**Server Settings (Dashboard → Dashboard → Server):**
- **Max Streaming Bitrate:** 120 Mbps (for 4K)
- **Hardware Acceleration:** VAAPI or NVENC
- **Transcoding Path:** Use SSD/RAM disk
- **Collection Scanning:** Scheduled during off-peak

**Database Optimization:**
```sql
-- Vacuum database monthly
sqlite3 /var/lib/jellyfin/data/library.db "VACUUM;"
```

---

### 10. Content Organization

**Smart Folders:**
```
/media/
├── movies/
│   ├── 4K/
│   ├── HD/
│   └── Classics/
├── tv/
│   ├── Series/
│   └── Documentaries/
└── live-tv/
    └── recordings/
```

**Library Types:**
- Movies: Use TMDb metadata
- TV Shows: Use ThetvDB
- Live TV: Use M3U + EPG

---

## 📋 Maintenance Schedule

### Daily (Automated)
- ✅ Channel health check (3 AM)
- ✅ Dead channel removal
- ✅ Health report generation

### Weekly (Manual)
- Review channel health reports
- Check logs for errors
- Test a few random channels

### Monthly (Manual)
- Update channels from IPTV-Org
- Vacuum database
- Review backup sizes
- Update Jellyfin server

### Quarterly
- Review and reorganize categories
- Add new channel sources
- Optimize transcoding settings
- Update plugins

---

## 🎓 Pro Tips

1. **Use Collections:** Group related content (Marvel movies, Star Trek series, etc.)

2. **Custom CSS:** Add custom branding via Dashboard → General → Custom CSS

3. **User Profiles:** Create separate profiles for family members with age restrictions

4. **Scheduled Tasks:** Use Dashboard → Scheduled Tasks for automation

5. **API Access:** Use Jellyfin API for custom integrations
   ```bash
   # Example: Get all channels
   curl "http://10.0.0.103:8096/LiveTv/Channels" \
     -H "X-Emby-Token: YOUR_API_KEY"
   ```

6. **Discord Integration:** Use webhooks to notify Discord channel of new content

7. **Watch Together:** Use Syncplay plugin for synchronized viewing with friends

8. **DVR:** Enable Live TV recording for time-shifting your favorite shows

---

## 🆘 Troubleshooting

### Channels Not Loading
```bash
# Check M3U file
grep -c "^#EXTINF:" /path/to/m3u

# Test a specific channel
curl -I "http://channel-url"

# Check Jellyfin logs
docker logs jellyfin-simonadmin | grep -i "live tv"
```

### High CPU Usage
- Enable hardware transcoding
- Lower max concurrent streams
- Check for stuck transcoding sessions

### Database Corruption
```bash
# Check database
sqlite3 /var/lib/jellyfin/data/library.db "PRAGMA integrity_check;"

# Repair if needed
sqlite3 /var/lib/jellyfin/data/library.db "VACUUM;"
```

---

## 📚 Resources

- **Official Docs:** https://jellyfin.org/docs/
- **Live TV Guide:** https://jellyfin.org/docs/general/server/live-tv/
- **API Docs:** https://api.jellyfin.org/
- **Community:** https://forum.jellyfin.org/
- **IPTV-Org:** https://github.com/iptv-org/iptv

---

## ✅ Your Current Setup

```
✅ Live TV: 311 channels configured
✅ SSL/HTTPS: Working with Cloudflare
✅ JavaScript Fix: Userscript ready
✅ Auto-Monitor: Runs daily at 3 AM
✅ Health Reports: HTML reports generated
✅ Backups: Automatic M3U backups
✅ Quick Commands: Installed
```

**Access:**
- HTTPS: https://jellyfin.simondatalab.de
- Live TV: https://jellyfin.simondatalab.de/web/#/livetv.html
- Reports: `reports/jellyfin/channel-health-*.html`

**Next Steps:**
1. Install Tampermonkey userscript
2. Run initial channel test
3. Review first health report
4. Setup EPG data (optional)
5. Install favorite plugins

---

**Your Jellyfin is now AWESOME! 🎉**
