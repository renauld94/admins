# 🎬 Jellyfin IPTV - Quick Start Guide

## ✅ Setup Complete!

### Infrastructure Status:

| Component | Status | Details |
|-----------|--------|---------|
| **VM** | ✅ Running | VM 200 at 10.0.0.103 |
| **Jellyfin Container** | ✅ Healthy | jellyfin-simonadmin |
| **Direct Access** | ✅ Working | http://136.243.155.166:8096 |
| **Cloudflare Route** | ✅ Added | Route #10: jellyfin.simondatalab.de → http://10.0.0.103:8096 |
| **DNS** | ✅ Configured | jellyfin.simondatalab.de |

---

## 🚀 Next Steps: Add IPTV Channels

### Step 1: Install IPTV Channel Playlists

Run this command to download and install IPTV channels from iptv-org:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./setup_jellyfin_iptv.sh
```

**What this does:**
- Downloads M3U playlists from https://github.com/iptv-org/iptv
- Uploads to VM 200
- Installs into Jellyfin container at `/config/data/playlists/`
- Sets proper permissions
- Provides 1000+ TV channels from multiple countries

---

### Step 2: Configure M3U Tuners in Jellyfin

1. **Access Jellyfin:**
   - Via tunnel: https://jellyfin.simondatalab.de
   - Or direct: http://136.243.155.166:8096/web/

2. **Login:** simonadmin

3. **Add Tuner:**
   - Navigate: **Admin Dashboard** → **Live TV** → **Tuners**
   - Click: **"+" (Add)** or **"Add Tuner"**
   - Select: **"M3U Tuner"**

4. **Configure Tuner:**
   ```
   Tuner Type: M3U Tuner
   File or URL: /config/data/playlists/iptv_org_international.m3u
   
   OR add multiple tuners for different playlists:
   - /config/data/playlists/iptv_org_categories.m3u
   - /config/data/playlists/iptv_org_languages.m3u
   - /config/data/playlists/iptv_org_countries.m3u
   - /config/data/playlists/iptv_org_country_us.m3u
   - /config/data/playlists/iptv_org_country_uk.m3u
   - /config/data/playlists/iptv_org_country_de.m3u
   etc.
   ```

5. **Save** the tuner configuration

---

### Step 3: Add EPG (Program Guide) Data

Run the EPG setup script:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./add_iptv_org_epg.sh
```

**What this does:**
- Downloads EPG XML files for 20+ countries
- Uploads to VM 200
- Installs into Jellyfin container at `/config/iptv_org_epg_*.xml`
- Provides program schedule data

**Then configure in Jellyfin:**
1. Navigate: **Admin Dashboard** → **Live TV** → **TV Guide Data Providers**
2. Click: **"+" (Add)**
3. Select: **"XMLTV"**
4. Configure:
   ```
   File or URL: /config/iptv_org_epg_us.xml
   
   OR add multiple EPG sources:
   - /config/iptv_org_epg_uk.xml
   - /config/iptv_org_epg_de.xml
   - /config/iptv_org_epg_fr.xml
   etc.
   ```
5. **Save** the configuration

---

### Step 4: Refresh Guide Data

1. Navigate: **Admin Dashboard** → **Scheduled Tasks**
2. Find: **"Refresh Guide"**
3. Click: **"Run Task"** (play button)
4. Wait: 5-10 minutes for data to populate

---

## 📺 Access Your IPTV

### Via Web Browser:
- **Public (HTTPS)**: https://jellyfin.simondatalab.de
- **Direct (HTTP)**: http://136.243.155.166:8096

### Via Jellyfin Apps:
1. Download **Jellyfin** app (iOS/Android/Smart TV)
2. Server: `https://jellyfin.simondatalab.de`
3. Username: `simonadmin`
4. Navigate to: **Live TV**

---

## 🔧 Quick Commands Reference

### Check Jellyfin Status
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps | grep jellyfin'
```

### Restart Jellyfin
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'
```

### Check Installed Playlists
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 \
  'docker exec jellyfin-simonadmin ls -lh /config/data/playlists/'
```

### Check EPG Files
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 \
  'docker exec jellyfin-simonadmin ls -lh /config/iptv_org_epg_*.xml'
```

### View Jellyfin Logs
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 \
  'docker logs -f jellyfin-simonadmin'
```

---

## 📋 Troubleshooting

### Tunnel not working (530 error)?
Wait a few minutes for the cloudflared tunnel to refresh its configuration, or:
```bash
# Find and restart the cloudflared container
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart cloudflared'
```

### Channels not loading?
- Check that M3U tuner is configured correctly
- Verify playlist files exist in container
- Some IPTV streams may be offline (this is normal with free IPTV)
- Try different channels

### EPG data not showing?
- Make sure you added XMLTV guide provider
- Run "Refresh Guide" task
- Wait 5-10 minutes for data to populate
- Check EPG files exist in container

---

## 🎯 What You'll Get

After complete setup:
- ✅ **1000+ TV channels** from around the world
- ✅ **Program guide data** with schedules and descriptions
- ✅ **Secure HTTPS access** via Cloudflare tunnel
- ✅ **Mobile apps** support (iOS/Android)
- ✅ **Smart TV apps** support
- ✅ **Recording capabilities** (if enabled in Jellyfin)

---

## 📚 Documentation

- **Full Guide**: `JELLYFIN_IPTV_COMPLETE_GUIDE.md`
- **EPG Setup**: `IPTV_EPG_SETUP_README.md`
- **IPTV Source**: https://github.com/iptv-org/iptv
- **Jellyfin Docs**: https://jellyfin.org/docs/

---

**🎯 VM**: 200 (10.0.0.103)  
**🔧 Container**: jellyfin-simonadmin  
**🌐 Public URL**: https://jellyfin.simondatalab.de  
**🔗 Direct URL**: http://136.243.155.166:8096  
**👤 User**: simonadmin  
**📅 Setup**: October 15, 2025

---

## ⚡ Quick Start Command

To install everything now, run:

```bash
# Install IPTV channels
cd /home/simon/Learning-Management-System-Academy/scripts
./setup_jellyfin_iptv.sh

# Then install EPG data
./add_iptv_org_epg.sh
```

Then configure in Jellyfin web interface as described above!
