# 🌐 VPN Setup for Jellyfin IPTV - Bypass Geo-Blocking

## 🎯 Problem: Geo-Blocked IPTV Channels

Many IPTV streams are geo-restricted and will show errors like:
- "This content is not available in your region"
- "403 Forbidden"
- "Stream not available"
- Connection timeouts

**Solution:** Route Jellyfin traffic through a VPN to appear in a different country.

---

## ✅ Recommended VPN Solutions for IPTV

### Option 1: Gluetun (Docker VPN Container) ⭐ RECOMMENDED

**Advantages:**
- Docker-based, integrates with Jellyfin container
- Supports multiple VPN providers
- Kill switch (blocks traffic if VPN disconnects)
- Easy to configure
- Can route specific containers through VPN

**Supported Providers:**
- NordVPN
- ExpressVPN
- Surfshark
- ProtonVPN
- Mullvad
- Private Internet Access (PIA)
- Many others

### Option 2: WireGuard (Native VPN)

**Advantages:**
- Fast and lightweight
- Built into Linux kernel
- Low overhead
- Self-hosted option available

### Option 3: OpenVPN (Traditional)

**Advantages:**
- Wide provider support
- Mature and stable
- Lots of documentation

---

## 🚀 Setup Guide: Gluetun with Jellyfin

### Architecture

Instead of:
```
Internet → Jellyfin → IPTV Streams (geo-blocked)
```

We create:
```
Internet → Jellyfin → Gluetun VPN → IPTV Streams (appear from VPN country)
```

### Step 1: Choose a VPN Provider

**Recommended for IPTV:**
1. **NordVPN** - Fast, reliable, many server locations
2. **Surfshark** - Unlimited devices, good price
3. **ProtonVPN** - Privacy-focused, free tier available
4. **Mullvad** - Anonymous, accepts crypto

**Sign up** for one of these services and get:
- Username/email
- Password
- Server location preference (US, UK, etc.)

### Step 2: Install Gluetun on VM 200

SSH into VM 200:
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103
```

Create Gluetun container configuration:
```bash
docker run -d \\
  --name=gluetun \\
  --cap-add=NET_ADMIN \\
  --device /dev/net/tun \\
  -e VPN_SERVICE_PROVIDER=nordvpn \\
  -e VPN_TYPE=openvpn \\
  -e OPENVPN_USER=your_nordvpn_email \\
  -e OPENVPN_PASSWORD=your_nordvpn_password \\
  -e SERVER_COUNTRIES=United States \\
  -p 8888:8888/tcp \\
  --restart=unless-stopped \\
  qmcgaw/gluetun
```

**For other providers, change:**
- `VPN_SERVICE_PROVIDER=` (surfshark, protonvpn, mullvad, etc.)
- `OPENVPN_USER=` and `OPENVPN_PASSWORD=` (your credentials)
- `SERVER_COUNTRIES=` (target country)

### Step 3: Configure Jellyfin to Use VPN

**Method A: Route All Jellyfin Traffic Through VPN**

Modify Jellyfin docker-compose or recreate container with network mode:
```yaml
services:
  jellyfin:
    network_mode: "container:gluetun"
    depends_on:
      - gluetun
```

**Method B: HTTP Proxy (Simpler)**

Configure Jellyfin to use Gluetun as HTTP proxy:
1. Access Jellyfin: http://136.243.155.166:8096
2. Admin Dashboard → Networking
3. Set HTTP Proxy: `http://localhost:8888`

---

## 🔧 Quick Setup Script

I'll create a script to set this up automatically.

### Before Running

1. **Get VPN credentials** from your provider
2. **Choose target country** (where you want to appear)
3. **Backup Jellyfin** configuration

### VPN Provider Examples

**NordVPN:**
```bash
VPN_PROVIDER=nordvpn
VPN_USER=your_email@example.com
VPN_PASS=your_password
SERVER_COUNTRY="United States"
```

**Surfshark:**
```bash
VPN_PROVIDER=surfshark
VPN_USER=your_email@example.com
VPN_PASS=your_password
SERVER_COUNTRY="United Kingdom"
```

**ProtonVPN:**
```bash
VPN_PROVIDER=protonvpn
VPN_USER=your_openvpn_username
VPN_PASS=your_openvpn_password
SERVER_COUNTRY="Germany"
```

---

## ⚙️ Alternative: Per-Stream VPN (Advanced)

If you only want VPN for specific channels:

### Use Multiple Jellyfin Instances

1. **Jellyfin-Main** (no VPN) - for local/non-geo-blocked content
2. **Jellyfin-VPN-US** (US VPN) - for US channels
3. **Jellyfin-VPN-UK** (UK VPN) - for UK channels

Each runs in separate container with dedicated Gluetun instance.

---

## 🎯 Recommended Setup for Your Use Case

Based on your 10,000+ channels:

### Multi-Country VPN Strategy

1. **No VPN**: International/Global channels
   - Already in: `/config/data/playlists/iptv_org_international.m3u`

2. **US VPN**: US-specific channels (1,484 channels)
   - Playlist: `/config/data/playlists/iptv_org_country_us.m3u`
   - Gluetun: NordVPN → US servers

3. **UK VPN**: UK-specific channels (213 channels)
   - Playlist: `/config/data/playlists/iptv_org_country_uk.m3u`
   - Gluetun: NordVPN → UK servers

4. **EU VPN**: European channels (DE, FR, ES, IT)
   - Combined playlist
   - Gluetun: NordVPN → EU servers

---

## 📊 Performance Considerations

### VPN Impact on Streaming

| Aspect | Without VPN | With VPN |
|--------|-------------|----------|
| **Speed** | Full ISP speed | 70-90% (good VPN) |
| **Latency** | Low | +10-50ms |
| **Reliability** | High | High (with kill switch) |
| **Channel Access** | Limited | Unlimited |

**Recommendation:** Use VPN only for geo-blocked channels.

---

## 🔐 Free VPN Options (Not Recommended for IPTV)

**Why not free VPNs?**
- Slow speeds (buffering issues)
- Limited bandwidth
- Unreliable connections
- Privacy concerns
- Often blocked by streaming services

**If you must use free:**
- ProtonVPN (has free tier, but slow)
- Windscribe (10GB/month free)

---

## 🚀 Next Steps

1. **Choose VPN provider** and sign up
2. **Run setup script** (I'll create this)
3. **Test with a geo-blocked channel**
4. **Organize channels** by country/category
5. **Enjoy unrestricted IPTV!**

---

## 📝 Quick Commands

### Check if VPN is working
```bash
# From inside Gluetun container
docker exec gluetun wget -qO- ifconfig.me
# Should show VPN IP, not your real IP
```

### Check VPN connection
```bash
docker logs gluetun | tail -n 20
# Should show "Tunnel is up"
```

### Restart VPN
```bash
docker restart gluetun
```

### Change VPN country
```bash
docker stop gluetun
docker rm gluetun
# Run docker run command with new SERVER_COUNTRIES=
```

---

**🎯 Bottom Line:** For best IPTV experience with 10,000+ channels, use:
1. **Gluetun VPN** for geo-blocked content
2. **Country-specific tuners** (US, UK, etc.) instead of one giant playlist
3. **Category filtering** (News, Sports, Movies, etc.)

This will give you organized, accessible, and reliable IPTV streaming!
