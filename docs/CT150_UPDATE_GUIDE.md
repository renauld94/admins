# CT 150 Portfolio Update Guide

## 🚀 Quick Start

Your CT 150 server (portfolio-web-1000150) needs updates. Follow these steps to update your portfolio at [https://www.simondatalab.de/](https://www.simondatalab.de/).

## 📋 Prerequisites

- Access to Proxmox server: `136.243.155.166`
- CT 150 server: `10.0.0.150` (portfolio-web-1000150)
- SSH access with appropriate credentials

## 🔧 Step-by-Step Update Process

### Step 1: Connect to CT 150 Server

```bash
# Option A: Direct connection via proxy jump
ssh -J root@136.243.155.166 simonadmin@10.0.0.150

# Option B: Two-step connection
ssh root@136.243.155.166
ssh simonadmin@10.0.0.150
```

### Step 2: Run the Update Script

```bash
# Copy the update script to CT 150
scp ct150_portfolio_update.sh ct150:/tmp/

# Connect to CT 150 and run the script
ssh ct150
sudo bash /tmp/ct150_portfolio_update.sh
```

### Step 3: Purge Cloudflare Cache

```bash
# Run the Cloudflare cache purge script
bash purge_cloudflare_cache.sh

# Or manually purge via Cloudflare dashboard:
# https://dash.cloudflare.com/ → Caching → Configuration → Purge Everything
```

## 🔍 What the Update Script Does

### System Updates
- ✅ Updates all system packages (`apt update && apt upgrade -y`)
- ✅ Checks disk space and cleans up if needed
- ✅ Verifies system performance metrics

### NGINX Configuration
- ✅ Checks NGINX status and configuration
- ✅ Updates Cloudflare IP ranges automatically
- ✅ Configures real IP headers for Cloudflare
- ✅ Reloads NGINX configuration

### Security & Firewall
- ✅ Reviews iptables rules and NAT configuration
- ✅ Checks port forwarding rules
- ✅ Verifies SSL certificate status

### Database & Services
- ✅ Checks MySQL/PostgreSQL status
- ✅ Reviews database tables and integrity
- ✅ Monitors service health

### Website Content
- ✅ Verifies website files in `/var/www/html/`
- ✅ Checks file permissions and ownership
- ✅ Analyzes recent logs for issues

## 🌐 Cloudflare Configuration

### Automatic IP Range Updates
The script automatically downloads and configures the latest Cloudflare IP ranges:

```nginx
# /etc/nginx/conf.d/cloudflare.conf
include /etc/nginx/cloudflare-ips.conf;

set_real_ip_from 0.0.0.0/0;
real_ip_header CF-Connecting-IP;
```

### Manual Cache Purge
If the automatic purge fails, use these methods:

1. **Cloudflare Dashboard:**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Select your domain
   - Go to Caching → Configuration
   - Click "Purge Everything"

2. **API Method:**
   ```bash
   curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
        -H "X-Auth-Email: sn.renauld@gmail.com" \
        -H "X-Auth-Key: YOUR_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{"purge_everything":true}'
   ```

## 🔧 Troubleshooting

### Connection Issues

If you can't connect to CT 150:

1. **Check Proxmox Status:**
   ```bash
   ping 136.243.155.166
   ssh root@136.243.155.166
   ```

2. **Check CT 150 from Proxmox:**
   ```bash
   ping 10.0.0.150
   ssh simonadmin@10.0.0.150
   ```

3. **Alternative Access:**
   - Use Proxmox web interface: `https://136.243.155.166:8006`
   - Access CT 150 console directly via Proxmox

### NGINX Issues

If NGINX fails to start:

```bash
# Check configuration
nginx -t

# Check logs
tail -f /var/log/nginx/error.log

# Restart NGINX
systemctl restart nginx
```

### Website Not Loading

1. **Check local access:**
   ```bash
   curl -I http://localhost
   curl -I https://localhost
   ```

2. **Check DNS resolution:**
   ```bash
   nslookup simondatalab.de
   dig simondatalab.de
   ```

3. **Check SSL certificates:**
   ```bash
   openssl x509 -in /etc/letsencrypt/live/simondatalab.de/fullchain.pem -noout -dates
   ```

## 📊 Monitoring & Verification

### After Update Checklist

- [ ] Website loads: https://www.simondatalab.de/
- [ ] SSL certificate is valid
- [ ] All services are running
- [ ] Cloudflare cache is purged
- [ ] No errors in logs
- [ ] Performance is acceptable

### Monitoring Commands

```bash
# Check service status
systemctl status nginx mysql postgresql

# Check disk usage
df -h

# Check memory usage
free -h

# Check active connections
ss -tuln | grep -E ':(80|443|22)'

# Check recent logs
tail -20 /var/log/nginx/access.log
tail -20 /var/log/nginx/error.log
```

## 🚨 Emergency Procedures

### If Website is Down

1. **Quick Fix:**
   ```bash
   systemctl restart nginx
   systemctl restart mysql  # if applicable
   ```

2. **Check Firewall:**
   ```bash
   iptables -L -n -v
   ufw status  # if using UFW
   ```

3. **Restore from Backup:**
   ```bash
   # Check available backups
   ls -la /var/backups/
   
   # Restore if needed
   cp -r /var/backups/website-backup-YYYYMMDD_HHMMSS/* /var/www/html/
   ```

### If Database Issues

```bash
# Check database status
systemctl status mysql postgresql

# Check database logs
tail -f /var/log/mysql/error.log
tail -f /var/log/postgresql/postgresql-*.log

# Repair if needed
mysqlcheck -r --all-databases
```

## 📞 Support Information

- **Server:** CT 150 (portfolio-web-1000150)
- **Proxmox Node:** pve
- **Domain:** simondatalab.de
- **Admin:** Simon Renauld (sn.renauld@gmail.com)

## 🔄 Regular Maintenance

### Weekly Tasks
- [ ] Check system updates
- [ ] Review logs for errors
- [ ] Verify backup status
- [ ] Check SSL certificate expiry

### Monthly Tasks
- [ ] Update Cloudflare IP ranges
- [ ] Review security logs
- [ ] Check disk space usage
- [ ] Test disaster recovery procedures

---

**Last Updated:** $(date)  
**Script Version:** 1.0  
**Status:** Ready for deployment
