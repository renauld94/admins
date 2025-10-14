# Manual Deployment Instructions for CT 150 Server

## Server Information
- **Server IP**: 10.0.0.150
- **Server Name**: portfolio-web
- **User**: root
- **Web Directory**: /var/www/html

## Current Issue
The server is not reachable from the current network location. This could be due to:
- Network segmentation/VLAN isolation
- Firewall rules
- Server being on a different network segment

## Manual Deployment Steps

### Option 1: Direct Server Access
If you have direct access to the server (console, KVM, etc.):

```bash
# 1. Create backup
mkdir -p /var/backups/website
cp -r /var/www/html/* /var/backups/website/$(date +%Y%m%d_%H%M%S)/

# 2. Download files from your local machine
# You can use scp, rsync, or copy files via USB/external storage

# 3. Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 4. Restart web services
systemctl reload nginx
# OR
systemctl restart apache2
```

### Option 2: VPN/Network Access
If you need to establish network connectivity:

1. **Check VPN connection** to the server's network
2. **Verify routing** to 10.0.0.0/24 network
3. **Test SSH connectivity**:
   ```bash
   ssh root@10.0.0.150
   ```

### Option 3: Alternative Upload Methods

#### Using SCP (when network is available):
```bash
scp -r /home/simon/Desktop/Learning\ Management\ System\ Academy/moodle-homepage/* root@10.0.0.150:/var/www/html/
```

#### Using rsync (when network is available):
```bash
rsync -avz --progress --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    "/home/simon/Desktop/Learning Management System Academy/moodle-homepage/" \
    "root@10.0.0.150:/var/www/html/"
```

## Files to Deploy

The following files have been updated and need to be deployed:

### Core Files:
- `index.html` - Main HTML with FAB and hero visualization
- `styles.css` - Updated with print CSS and FAB styles
- `app.js` - Updated with ScrollTrigger fixes
- `hero-performance.js` - New performance optimization script

### Key Updates:
1. **Floating Action Button** - Globe icon linking to simondatalab.de
2. **Print CSS** - Optimized print formatting
3. **Performance Optimizations** - Device detection and WebGL fallbacks
4. **Font Loading** - Updated Inter font with weight 800
5. **ScrollTrigger Fix** - Proper GSAP plugin registration

## Verification Steps

After deployment, verify:

1. **Website loads**: http://10.0.0.150
2. **FAB appears**: Globe icon in bottom-right corner
3. **Print preview**: Ctrl+P shows optimized print layout
4. **Performance**: Check browser console for performance logs
5. **Admin menu**: Verify admin dropdown works correctly

## Troubleshooting

### If website doesn't load:
```bash
# Check web server status
systemctl status nginx
systemctl status apache2

# Check web server logs
tail -f /var/log/nginx/error.log
tail -f /var/log/apache2/error.log

# Check file permissions
ls -la /var/www/html/
```

### If FAB doesn't appear:
- Check browser console for JavaScript errors
- Verify `hero-performance.js` is loading
- Check CSS is properly applied

### If admin menu doesn't work:
- Verify JavaScript is enabled
- Check for console errors
- Ensure proper file permissions

## Network Configuration

To establish connectivity to CT 150:

1. **Check current network**:
   ```bash
   ip route show
   ```

2. **Add route if needed**:
   ```bash
   sudo ip route add 10.0.0.0/24 via [gateway_ip]
   ```

3. **Test connectivity**:
   ```bash
   ping 10.0.0.150
   telnet 10.0.0.150 22
   ```

## Next Steps

1. **Establish network connectivity** to 10.0.0.150
2. **Run the deployment script** when connected
3. **Verify all functionality** works as expected
4. **Test on different devices** and browsers

---

**Note**: The deployment script is ready at `/home/simon/Desktop/Learning Management System Academy/deploy_to_ct150.sh` and can be executed once network connectivity is established.
