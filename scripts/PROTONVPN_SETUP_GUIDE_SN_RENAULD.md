# 🔒 ProtonVPN Free Setup Guide for sn.renauld@gmail.com

## 📋 Quick Start

### Step 1: Get ProtonVPN Account (If You Don't Have One)
1. **Sign up**: https://protonvpn.com/free-vpn
2. **Email**: `sn.renauld@gmail.com`
3. **Choose**: Free plan (no credit card required)
4. **Verify**: Check your email and verify account

### Step 2: Get OpenVPN Credentials
1. **Login**: https://account.protonvpn.com/account
2. **Email**: `sn.renauld@gmail.com`
3. **Find section**: "OpenVPN / IKEv2 username"
4. **Copy username**: Format like `user+f1234567`
5. **Copy password**: Long random string

> ⚠️ **IMPORTANT**: OpenVPN credentials are NOT the same as your ProtonVPN login!

### Step 3: Run Automated Setup Script
```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./setup_protonvpn_sn_renauld.sh
```

The script will:
- ✅ Check for existing Gluetun container
- ✅ Prompt for your OpenVPN credentials
- ✅ Let you choose server location (US/Netherlands/Japan)
- ✅ Install Gluetun VPN container
- ✅ Test VPN connection
- ✅ Show your VPN IP address

### Step 4: Configure Jellyfin
1. **Access**: http://136.243.155.166:8096/web/
2. **Login**: simonadmin
3. **Navigate**: Admin Dashboard → Playback
4. **HTTP Proxy**: Enable
5. **Proxy URL**: `http://10.0.0.103:8888`
6. **Save** and restart Jellyfin:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'
   ```

---

## 🌍 ProtonVPN Free Tier Features

| Feature | Free Tier |
|---------|-----------|
| **Data** | Unlimited ✅ |
| **Speed** | Medium |
| **Servers** | 3 countries (US, Netherlands, Japan) |
| **Devices** | 1 connection |
| **Cost** | $0/month ✅ |
| **Logs** | No logs policy |

---

## 🔧 Manual Setup (If Script Fails)

### Option 1: Direct Docker Command
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

docker run -d \
  --name=gluetun-proton-free \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e OPENVPN_USER='YOUR_OPENVPN_USERNAME' \
  -e OPENVPN_PASSWORD='YOUR_OPENVPN_PASSWORD' \
  -e SERVER_COUNTRIES='United States' \
  -e FREE_ONLY=on \
  -e HTTPPROXY=on \
  -e HTTPPROXY_LOG=on \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun
```

### Option 2: Step by Step
1. **SSH to VM 200**:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103
   ```

2. **Set credentials** (replace with your actual credentials):
   ```bash
   export PROTON_USER='user+f1234567'
   export PROTON_PASS='your_long_random_password'
   ```

3. **Run Docker command**:
   ```bash
   docker run -d \
     --name=gluetun-proton-free \
     --cap-add=NET_ADMIN \
     --device /dev/net/tun \
     -e VPN_SERVICE_PROVIDER=protonvpn \
     -e OPENVPN_USER="${PROTON_USER}" \
     -e OPENVPN_PASSWORD="${PROTON_PASS}" \
     -e SERVER_COUNTRIES="United States" \
     -e FREE_ONLY=on \
     -e HTTPPROXY=on \
     -p 8888:8888/tcp \
     --restart=unless-stopped \
     qmcgaw/gluetun
   ```

4. **Check status**:
   ```bash
   docker logs gluetun-proton-free
   ```

---

## 🧪 Testing & Verification

### Check VPN Container Status
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps | grep gluetun'
```

### Check VPN IP Address
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec gluetun-proton-free wget -qO- https://api.ipify.org'
```

### Check VPN Logs
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs --tail 50 gluetun-proton-free'
```

### Test Geo-Blocked Channel
1. Access Jellyfin: http://136.243.155.166:8096/web/#/livetv.html
2. Find a US-only channel (e.g., ABC, NBC, CBS)
3. Try to play it
4. If it works → VPN is routing traffic correctly ✅

---

## 🔄 Server Location Options

ProtonVPN Free offers 3 locations:

### United States
- **Best for**: US channels (ABC, NBC, CBS, Fox, etc.)
- **Server**: `SERVER_COUNTRIES='United States'`

### Netherlands
- **Best for**: European channels
- **Server**: `SERVER_COUNTRIES='Netherlands'`

### Japan
- **Best for**: Asian channels
- **Server**: `SERVER_COUNTRIES='Japan'`

To change server location:
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

# Stop and remove old container
docker stop gluetun-proton-free
docker rm gluetun-proton-free

# Run setup script again and choose different location
```

---

## 🛠️ Useful Commands

### Restart VPN
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart gluetun-proton-free'
```

### Stop VPN
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker stop gluetun-proton-free'
```

### Start VPN
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker start gluetun-proton-free'
```

### Remove VPN Container
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker stop gluetun-proton-free && docker rm gluetun-proton-free'
```

### View Real-Time Logs
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs -f gluetun-proton-free'
```
(Press Ctrl+C to exit)

---

## ⚠️ Troubleshooting

### Issue: Container Won't Start
**Check logs**:
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs gluetun-proton-free'
```

**Common causes**:
- Invalid OpenVPN credentials → Get fresh credentials from ProtonVPN account
- `/dev/net/tun` not available → Ensure TUN/TAP is enabled on VM
- Port 8888 already in use → Change port or stop conflicting service

### Issue: VPN Connected But Channels Still Blocked
**Check Jellyfin proxy settings**:
1. Admin Dashboard → Playback
2. Verify proxy URL: `http://10.0.0.103:8888`
3. Save and restart Jellyfin

**Verify VPN is routing traffic**:
```bash
# Check VPN IP
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec gluetun-proton-free wget -qO- https://api.ipify.org'

# Should show US/NL/JP IP, not your German IP
```

### Issue: Slow Streaming
**ProtonVPN Free has medium speed**, so:
- Lower Jellyfin streaming quality: Settings → Playback → Quality
- Try different server location (US vs NL vs JP)
- Consider upgrading to ProtonVPN Plus for faster speeds

### Issue: Authentication Failed
**Get fresh OpenVPN credentials**:
1. Login: https://account.protonvpn.com/account
2. Section: "OpenVPN / IKEv2 username"
3. Click "Reset OpenVPN password" if needed
4. Use new credentials in script

---

## 📊 Performance Expectations

### Free Tier Speeds
- **Download**: 2-10 Mbps (medium speed)
- **Best for**: SD quality streaming (480p-720p)
- **HD streaming**: May buffer on Free tier
- **4K streaming**: Not recommended on Free tier

### Upgrade Path
If you need faster speeds:
- **ProtonVPN Plus**: $4.99/month → High speed, 63 countries
- **ProtonVPN Unlimited**: $9.99/month → Highest speed, all features

---

## 🎯 Complete Setup Summary

### What You Need
1. ✅ ProtonVPN account with email: `sn.renauld@gmail.com`
2. ✅ OpenVPN username and password
3. ✅ SSH access to VM 200
4. ✅ Jellyfin running on VM 200

### Setup Process
1. ✅ Run `./setup_protonvpn_sn_renauld.sh`
2. ✅ Enter OpenVPN credentials when prompted
3. ✅ Choose server location (US/NL/JP)
4. ✅ Wait for container to start
5. ✅ Configure Jellyfin HTTP proxy
6. ✅ Test with geo-blocked channel

### Expected Results
- ✅ Gluetun container running on VM 200
- ✅ HTTP proxy available at `10.0.0.103:8888`
- ✅ VPN IP from chosen country (US/NL/JP)
- ✅ Geo-blocked channels now accessible
- ✅ Unlimited data usage (no caps)

---

## 🔐 Security Notes

### ProtonVPN Free Security
- ✅ No logs policy
- ✅ Strong encryption (OpenVPN)
- ✅ Based in Switzerland (privacy-friendly)
- ✅ Open source client
- ✅ Independently audited

### Best Practices
- 🔒 Keep OpenVPN credentials secure
- 🔒 Don't share credentials
- 🔒 Use strong ProtonVPN account password
- 🔒 Enable 2FA on ProtonVPN account

---

## 📞 Support Resources

### ProtonVPN Support
- **Help Center**: https://protonvpn.com/support/
- **Community**: https://www.reddit.com/r/ProtonVPN/
- **Status**: https://protonstatus.com/

### Gluetun Documentation
- **GitHub**: https://github.com/qdm12/gluetun
- **Wiki**: https://github.com/qdm12/gluetun/wiki

### Quick Links
- **ProtonVPN Login**: https://account.protonvpn.com/login
- **OpenVPN Credentials**: https://account.protonvpn.com/account
- **Free VPN Signup**: https://protonvpn.com/free-vpn

---

**📧 Account Email**: sn.renauld@gmail.com  
**🎯 Target VM**: 10.0.0.103 (VM 200)  
**🐳 Container**: gluetun-proton-free  
**🌐 Proxy Port**: 8888  
**💰 Cost**: $0/month (Free tier)  
**📊 Data Limit**: Unlimited ✅
