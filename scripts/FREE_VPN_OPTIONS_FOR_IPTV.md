# 🆓 Free VPN Options for Jellyfin IPTV

## ⚠️ Important Disclaimer

**Free VPNs have significant limitations for IPTV streaming:**
- 🐌 Slower speeds = buffering issues
- 📊 Data caps = limited viewing time
- 🔒 Some block streaming services
- ⏱️ Connection time limits
- 🔄 Unreliable connections

**For best IPTV experience, paid VPNs are recommended.** However, here are the best free options:

---

## ✅ Best Free VPN Options for IPTV

### 1. ProtonVPN Free ⭐ RECOMMENDED

**Why it's the best free option:**
- ✅ No data cap (unlimited!)
- ✅ Decent speeds for streaming
- ✅ Strong privacy (Switzerland-based)
- ✅ No logs policy
- ✅ Works with Gluetun

**Limitations:**
- ❌ Only 3 server locations (US, NL, JP)
- ❌ Medium priority (slower than paid)
- ❌ Only 1 connection at a time

**Setup with Gluetun:**
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

docker run -d --name=gluetun \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e VPN_TYPE=openvpn \
  -e OPENVPN_USER=your_protonvpn_openvpn_username \
  -e OPENVPN_PASSWORD=your_protonvpn_openvpn_password \
  -e SERVER_COUNTRIES="United States" \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

**Get ProtonVPN Free:**
1. Sign up: https://protonvpn.com/free-vpn
2. Go to Account → OpenVPN credentials
3. Get your OpenVPN username and password (different from login!)
4. Use credentials in Gluetun setup above

---

### 2. Windscribe Free

**Features:**
- ✅ 10GB/month free
- ✅ 10 server locations
- ✅ Good speeds
- ✅ Works with streaming

**Limitations:**
- ❌ 10GB/month limit (~20 hours of SD streaming)
- ❌ Email required
- ❌ Can earn extra 5GB by tweeting

**Setup with Gluetun:**
```bash
docker run -d --name=gluetun \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=windscribe \
  -e VPN_TYPE=openvpn \
  -e OPENVPN_USER=your_windscribe_username \
  -e OPENVPN_PASSWORD=your_windscribe_password \
  -e SERVER_COUNTRIES="United States" \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

**Get Windscribe:**
- Sign up: https://windscribe.com/signup
- Free plan: 10GB/month
- Build a plan: $1/month per location (cheap alternative!)

---

### 3. Hide.me Free

**Features:**
- ✅ 10GB/month free
- ✅ No registration required
- ✅ 5 server locations
- ✅ Fast speeds

**Limitations:**
- ❌ 10GB/month limit
- ❌ Limited locations
- ❌ 1 device only

**Not directly supported by Gluetun** - Would need manual OpenVPN config.

---

### 4. TunnelBear Free

**Features:**
- ✅ 500MB/month (2GB with tweet)
- ✅ 40+ server locations
- ✅ Easy to use

**Limitations:**
- ❌ Only 500MB/month (very limited for IPTV)
- ❌ Not enough for streaming

**Not recommended for IPTV** due to very low data cap.

---

## 🎯 Recommended Free Setup for IPTV

### Option 1: ProtonVPN Free (Best Choice)

**Pros:**
- Unlimited data ✅
- Works 24/7 ✅
- No payment required ✅

**Cons:**
- Slower speeds during peak hours
- Only US, Netherlands, or Japan servers
- Medium priority (lower than paid users)

**Perfect for:**
- Testing if VPN helps with your geo-blocked channels
- Long-term free solution if speed is acceptable
- US IPTV channels (US server available)

### Option 2: Windscribe Free + Paid Combo

**Strategy:**
- Use free 10GB for testing
- If works well, upgrade to "Build a Plan"
- $1/month per location (e.g., $3 for US + UK + EU)
- Much cheaper than full VPN subscriptions

**Perfect for:**
- Budget-conscious users
- Only need specific countries
- Want flexibility

---

## 🆓 Self-Hosted VPN (Completely Free!)

### WireGuard on Oracle Cloud (Free Forever)

**What is this:**
- Set up your own VPN server on Oracle Cloud
- Oracle offers free forever VM instances
- You control everything
- No data caps, no speed limits

**Setup Steps:**

#### 1. Create Oracle Cloud Free Account
- Go to: https://www.oracle.com/cloud/free/
- Sign up (requires credit card for verification, but won't be charged)
- Get "Always Free" tier

#### 2. Create Free VM Instance
```
Location: US (or your target region)
OS: Ubuntu 22.04
Instance: VM.Standard.E2.1.Micro (Always Free)
```

#### 3. Install WireGuard
SSH into Oracle VM and run:
```bash
# Install WireGuard
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh
```

#### 4. Connect Jellyfin to WireGuard
Use Gluetun with WireGuard:
```bash
docker run -d --name=gluetun \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=custom \
  -e VPN_TYPE=wireguard \
  -e WIREGUARD_PRIVATE_KEY=your_private_key \
  -e WIREGUARD_PUBLIC_KEY=server_public_key \
  -e WIREGUARD_ENDPOINT_IP=oracle_vm_ip \
  -e WIREGUARD_ENDPOINT_PORT=51820 \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

**Advantages:**
- ✅ 100% free forever
- ✅ No data caps
- ✅ No speed limits (Oracle has good bandwidth)
- ✅ Full control
- ✅ Choose any location Oracle offers

**Disadvantages:**
- ❌ More technical setup
- ❌ One location only (create multiple VMs for more)
- ❌ Requires maintenance

---

## 📊 Free VPN Comparison Table

| Provider | Data Cap | Speed | Locations | IPTV Suitable? | Setup Difficulty |
|----------|----------|-------|-----------|----------------|------------------|
| **ProtonVPN** | Unlimited | Medium | 3 (US, NL, JP) | ⭐⭐⭐⭐ Good | Easy |
| **Windscribe** | 10GB/month | Fast | 10 | ⭐⭐⭐ OK | Easy |
| **Hide.me** | 10GB/month | Fast | 5 | ⭐⭐⭐ OK | Medium |
| **TunnelBear** | 500MB/month | Fast | 40+ | ⭐ Poor | Easy |
| **Oracle WireGuard** | Unlimited | Very Fast | Any Oracle region | ⭐⭐⭐⭐⭐ Excellent | Hard |

---

## 🚀 Quick Start: ProtonVPN Free Setup

### Step 1: Sign Up
1. Go to: https://protonvpn.com/free-vpn
2. Create free account
3. Verify email

### Step 2: Get OpenVPN Credentials
1. Login to ProtonVPN account
2. Go to: Account → OpenVPN/IKEv2 username
3. Copy username and password (NOT your login credentials!)

### Step 3: Install on VM 200
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

docker run -d --name=gluetun-free \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e VPN_TYPE=openvpn \
  -e OPENVPN_USER=your_openvpn_username \
  -e OPENVPN_PASSWORD=your_openvpn_password \
  -e SERVER_COUNTRIES="United States" \
  -e FREE_ONLY=on \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

**Important:** Add `-e FREE_ONLY=on` to only use free servers!

### Step 4: Configure Jellyfin
1. Go to: http://136.243.155.166:8096/web/
2. Admin Dashboard → Networking
3. HTTP Proxy: `http://10.0.0.103:8888`
4. Save

### Step 5: Test
```bash
# Check VPN connection
docker logs gluetun-free | tail -n 20

# Verify IP changed
docker exec gluetun-free wget -qO- ifconfig.me
```

---

## 💡 Tips for Using Free VPN with IPTV

### 1. Lower Quality During Peak Hours
If buffering occurs:
- Watch at lower quality (480p instead of 1080p)
- Avoid peak hours (6 PM - 10 PM)

### 2. Use VPN Only for Geo-Blocked Channels
**Strategy:**
- Keep 2 sets of tuners in Jellyfin:
  - "Global IPTV" - No VPN needed
  - "US IPTV" - Routed through ProtonVPN
- Only use VPN when needed

### 3. Windscribe Data Management
With 10GB/month limit:
- SD quality: ~500MB/hour = 20 hours
- HD quality: ~2GB/hour = 5 hours
- Monitor usage: https://windscribe.com/myaccount

### 4. Multiple Free Accounts (Not Recommended)
**Don't do this:**
- Violates ToS
- Accounts may be banned
- Use paid or self-hosted instead

---

## 🎯 My Recommendation for You

Based on your 10,000+ IPTV channels:

### Best Free Option: ProtonVPN Free
**Setup:**
1. Sign up for ProtonVPN Free
2. Install Gluetun with ProtonVPN
3. Connect to US server (most US channels)
4. Keep only country tuners you use:
   - US channels → ProtonVPN US server
   - EU channels → ProtonVPN NL server
   - Japan channels → ProtonVPN JP server
   - Global channels → No VPN

**Cost:** $0
**Effort:** 30 minutes setup
**Result:** Unlimited free VPN for IPTV!

### Best Budget Option: Windscribe Build-a-Plan
**Setup:**
1. Try Windscribe free (10GB)
2. If works well, upgrade to Build-a-Plan
3. $1/month per location
4. Example: US ($1) + UK ($1) + EU ($1) = $3/month total

**Cost:** $1-3/month (cheaper than full VPN)
**Effort:** 20 minutes
**Result:** Fast VPN for specific countries

### Best DIY Option: Oracle Cloud WireGuard
**Setup:**
1. Create Oracle Cloud free account
2. Deploy free VM in US region
3. Install WireGuard
4. Connect Jellyfin via Gluetun

**Cost:** $0 forever
**Effort:** 2-3 hours initial setup
**Result:** Your own private VPN server!

---

## 📚 Additional Resources

**ProtonVPN Free:**
- Signup: https://protonvpn.com/free-vpn
- OpenVPN guide: https://protonvpn.com/support/vpn-config-download/

**Windscribe:**
- Signup: https://windscribe.com/signup
- Build-a-Plan: https://windscribe.com/upgrade

**Oracle Cloud WireGuard:**
- Oracle Free Tier: https://www.oracle.com/cloud/free/
- WireGuard Install Script: https://github.com/angristan/wireguard-install

**Gluetun Documentation:**
- GitHub: https://github.com/qdm12/gluetun
- Supported VPNs: https://github.com/qdm12/gluetun-wiki

---

## 🎬 Ready to Start?

**For immediate testing (FREE):**
```bash
# 1. Sign up: https://protonvpn.com/free-vpn
# 2. Get OpenVPN credentials from account page
# 3. Run this on VM 200:

ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

docker run -d --name=gluetun-proton-free \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e OPENVPN_USER=PASTE_YOUR_OPENVPN_USERNAME \
  -e OPENVPN_PASSWORD=PASTE_YOUR_OPENVPN_PASSWORD \
  -e SERVER_COUNTRIES="United States" \
  -e FREE_ONLY=on \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun

# 4. Configure Jellyfin HTTP Proxy: http://10.0.0.103:8888
# 5. Test geo-blocked channels!
```

**Total Cost:** $0  
**Time to Setup:** 15 minutes  
**Result:** Free VPN for your IPTV! 🎉
