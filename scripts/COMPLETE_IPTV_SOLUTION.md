# 📺 COMPLETE SOLUTION: Organize 10,000+ IPTV Channels + VPN for Geo-Blocking

## 🎯 Your Current Situation

✅ **Working:**
- Jellyfin installed on VM 200 (10.0.0.103)
- 10,000+ IPTV channels loaded
- Access: http://136.243.155.166:8096/web/#/livetv.html

⚠️ **Problems:**
1. Too many channels - hard to find what you want
2. Some channels geo-blocked (not accessible from your location)

---

## ✅ Solution 1: Organize Channels (Do This First!)

### Problem with Current Setup
You loaded ALL these playlists:
- International: 11,340 channels
- Categories: 11,673 channels
- Languages: 12,242 channels
- Countries: 12,094 channels
- **Total: Way too many duplicates and overwhelming!**

### Recommended Organization Strategy

#### Option A: Country-Based (Simplest) ⭐ RECOMMENDED

Keep only country-specific tuners for manageable channel counts:

1. **Remove large tuners:**
   - Go to: Admin Dashboard → Live TV → Tuners
   - Delete: iptv_org_international, iptv_org_categories, iptv_org_languages, iptv_org_countries

2. **Keep only country tuners:**
   - ✅ USA (1,484 channels)
   - ✅ UK (213 channels)
   - ✅ Germany (273 channels)
   - ✅ France (196 channels)
   - Total: ~2,400 channels (much better!)

3. **Add tuners in Jellyfin:**
   ```
   Admin Dashboard → Live TV → Add Tuner → M3U Tuner
   
   Tuner 1: USA Channels
   Path: /config/data/playlists/iptv_org_country_us.m3u
   
   Tuner 2: UK Channels
   Path: /config/data/playlists/iptv_org_country_uk.m3u
   
   Tuner 3: German Channels
   Path: /config/data/playlists/iptv_org_country_de.m3u
   
   Tuner 4: French Channels
   Path: /config/data/playlists/iptv_org_country_fr.m3u
   ```

#### Option B: Category-Based (More Work, Better Organization)

Create filtered playlists by type:
- **News** (CNN, BBC, Fox News, etc.)
- **Sports** (ESPN, NBA, NFL, etc.)
- **Movies** (HBO, Cinema channels)
- **Kids** (Disney, Nickelodeon)
- **Music** (MTV, VH1)
- **Documentary** (Discovery, Nat Geo)

**Run this script to create category playlists:**
```bash
cd /home/simon/Learning-Management-System-Academy/scripts
chmod +x create_popular_categories.sh
./create_popular_categories.sh
```

This will create:
- `popular_news.m3u`
- `popular_sports.m3u`
- `popular_movies.m3u`
- etc.

Then add each as a separate tuner in Jellyfin.

---

## ✅ Solution 2: Setup VPN for Geo-Blocked Channels

### Why You Need VPN

Many channels are geo-blocked:
- **US channels** → Only work from US IP
- **UK channels** → Only work from UK IP
- **Sports events** → Regional restrictions

**Without VPN:** "This content is not available in your region" ❌  
**With VPN:** Channels work perfectly! ✅

### Recommended VPN Setup: Gluetun (Docker Container)

**Step-by-step:**

#### 1. Get a VPN subscription

**Best for IPTV:**
- NordVPN (~$3-5/month)
- Surfshark (~$2-3/month)
- ProtonVPN (has free tier, but slow)

#### 2. Install Gluetun on VM 200

```bash
# SSH into VM 200
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

# Install Gluetun VPN container
docker run -d \
  --name=gluetun \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=nordvpn \
  -e VPN_TYPE=openvpn \
  -e OPENVPN_USER=your_email@example.com \
  -e OPENVPN_PASSWORD=your_password \
  -e SERVER_COUNTRIES="United States" \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

**Change:**
- `VPN_SERVICE_PROVIDER=` to your provider (nordvpn, surfshark, protonvpn)
- `OPENVPN_USER=` your VPN email/username
- `OPENVPN_PASSWORD=` your VPN password
- `SERVER_COUNTRIES=` target country (United States, United Kingdom, Germany, etc.)

#### 3. Configure Jellyfin to use VPN

**Option A: Simple HTTP Proxy (Recommended)**

In Jellyfin web interface:
1. Admin Dashboard → Networking
2. HTTP Proxy Server: `http://10.0.0.103:8888`
3. Save

**Option B: Route Entire Container (Advanced)**

Modify Jellyfin container to use Gluetun network:
```bash
docker stop jellyfin-simonadmin
# Recreate with network_mode: "container:gluetun"
```

#### 4. Test VPN is working

```bash
# Check VPN IP
docker exec gluetun wget -qO- ifconfig.me
# Should show VPN server IP, not your real IP

# Check connection status
docker logs gluetun | tail -n 20
# Should show "Tunnel is up"
```

---

## 🎯 Complete Setup Workflow

### Step 1: Organize Channels (15 minutes)

1. Go to Jellyfin: http://136.243.155.166:8096/web/
2. Admin Dashboard → Live TV → Tuners
3. **Remove** all tuners with 10,000+ channels
4. **Add** country-specific tuners (US, UK, DE, FR) = ~2,400 total
5. Or run category script for filtered playlists

### Step 2: Setup VPN (20 minutes)

1. **Sign up** for NordVPN or Surfshark
2. **SSH** into VM 200
3. **Run** Gluetun docker container with your credentials
4. **Configure** Jellyfin to use HTTP proxy
5. **Test** geo-blocked channels

### Step 3: Optimize (Optional)

- Create multiple Gluetun instances for different countries
- Setup country-specific tuners with matching VPN
- Add EPG data for program guides

---

## 📊 Before vs After

### Before
- ❌ 10,000+ channels (overwhelming)
- ❌ Many geo-blocked channels won't play
- ❌ Hard to find specific content
- ❌ Duplicate channels everywhere

### After
- ✅ ~2,400 organized channels (by country or category)
- ✅ Geo-blocked channels work via VPN
- ✅ Easy to browse by country/category
- ✅ No duplicates, clean interface

---

## 🚀 Quick Start Commands

### Reorganize Channels (Country-Based)
```bash
# In Jellyfin Web UI:
# 1. Delete large tuners
# 2. Add: /config/data/playlists/iptv_org_country_us.m3u
# 3. Add: /config/data/playlists/iptv_org_country_uk.m3u
# 4. Add: /config/data/playlists/iptv_org_country_de.m3u
# 5. Add: /config/data/playlists/iptv_org_country_fr.m3u
```

### Create Category Playlists
```bash
cd /home/simon/Learning-Management-System-Academy/scripts
chmod +x create_popular_categories.sh
./create_popular_categories.sh
```

### Setup VPN (NordVPN example)
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

docker run -d --name=gluetun --cap-add=NET_ADMIN --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=nordvpn \
  -e OPENVPN_USER=your_email \
  -e OPENVPN_PASSWORD=your_password \
  -e SERVER_COUNTRIES="United States" \
  -p 8888:8888/tcp --restart=unless-stopped qmcgaw/gluetun
```

---

## 📚 Documentation Created

All guides saved in `/home/simon/Learning-Management-System-Academy/scripts/`:

1. **organize_jellyfin_iptv_channels.md** - Channel organization strategies
2. **VPN_SETUP_FOR_IPTV.md** - Complete VPN setup guide
3. **create_popular_categories.sh** - Automated category filter script

---

## 💡 Pro Tips

### VPN Country Strategy

Match VPN country to channel country:
- **US channels** → Gluetun with US servers
- **UK channels** → Gluetun with UK servers
- **EU channels** → Gluetun with EU servers
- **Global channels** → No VPN needed

### Multiple VPN Instances (Advanced)

Run separate Gluetun containers for each region:
```bash
# US VPN
docker run -d --name=gluetun-us ... -e SERVER_COUNTRIES="United States" -p 8888:8888 ...

# UK VPN
docker run -d --name=gluetun-uk ... -e SERVER_COUNTRIES="United Kingdom" -p 8889:8888 ...

# EU VPN
docker run -d --name=gluetun-eu ... -e SERVER_COUNTRIES="Germany" -p 8890:8888 ...
```

Then configure different Jellyfin instances or use HTTP proxy per tuner.

---

## 🎯 Recommended Setup for You

Based on 10,000+ channels:

1. **Keep only 4 country tuners** (~2,400 channels)
   - USA: 1,484 channels
   - UK: 213 channels
   - Germany: 273 channels
   - France: 196 channels

2. **Setup single VPN** (US-based for most content)
   - Use NordVPN or Surfshark
   - Connect to US servers
   - Configure Jellyfin HTTP proxy

3. **Test and adjust**
   - Try channels
   - Change VPN country if needed
   - Add more countries later

**Result:** Clean, organized IPTV with geo-blocked content working! 🎉

---

**Next Steps:**
1. Remove large tuners from Jellyfin
2. Add country-specific tuners
3. Sign up for NordVPN/Surfshark
4. Install Gluetun
5. Enjoy organized, unrestricted IPTV!
