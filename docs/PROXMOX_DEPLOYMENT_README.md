# 🚀 Portfolio Deployment Guide for Proxmox VM

## 📋 Deployment Overview
Deploy your enhanced portfolio to your Proxmox VM at `http://136.243.155.166:8082/`

## 📦 What's Included
- ✅ **Enhanced Portfolio** with all creative features
- ✅ **Deployment Script** for easy installation
- ✅ **All Assets** (CSS, JS, Images, Fonts)

## 🎯 Enhanced Features
- ✨ Interactive project cards with hover animations
- 📊 Animated counters and skill progress bars
- 🌙 Dark mode toggle with professional styling
- 📈 Scroll progress indicator
- 🎯 Enhanced timeline animations
- 🧠 Neuroscience demo interactions
- 🌍 Geospatial map interactions
- 🔄 Floating skill badges
- ⬆️ Back-to-top button
- 🔔 Notification system
- 📱 Mobile-optimized responsive design

## 📤 Deployment Steps

### Method 1: Direct Transfer (Recommended)
1. **Locate the deployment package:**
   ```
   /home/simon/Desktop/Learning Management System Academy/portofio_simon_rennauld/simonrenauld.github.io/portfolio_proxmox_deployment.tar.gz
   ```

2. **Transfer to Proxmox Server:**
   - Use USB drive, network share, or any file transfer method
   - Copy `portfolio_proxmox_deployment.tar.gz` to your Proxmox server

3. **On Proxmox Server (as root):**
   ```bash
   # Navigate to where you placed the file
   cd /path/to/deployment/file

   # Extract the package
   tar -xzf portfolio_proxmox_deployment.tar.gz

   # Run the deployment script
   chmod +x deploy_on_proxmox.sh
   ./deploy_on_proxmox.sh
   ```

### Method 2: Manual Deployment
If you can't transfer the package, you can manually copy files:

1. **Copy portfolio files to Proxmox:**
   ```
   scp -r /home/simon/Desktop/Learning\ Management\ System\ Academy/portofio_simon_rennauld/simonrenauld.github.io/* root@136.243.155.166:/var/www/html/portfolio/
   ```

2. **On Proxmox Server (as root):**
   ```bash
   # Set proper permissions
   chown -R www-data:www-data /var/www/html/portfolio/
   chmod -R 755 /var/www/html/portfolio/

   # Restart nginx if needed
   systemctl restart nginx
   ```

## 🔧 Troubleshooting

### If SSH Connection Fails:
- Check SSH server status: `systemctl status ssh`
- Verify SSH keys: `ls -la ~/.ssh/`
- Check firewall: `ufw status` or `iptables -L`

### If Web Server Issues:
- Check nginx config: `cat /etc/nginx/sites-available/default`
- Test nginx: `nginx -t`
- Restart nginx: `systemctl restart nginx`
- Check logs: `tail -f /var/log/nginx/error.log`

### If Files Don't Load:
- Verify file permissions: `ls -la /var/www/html/portfolio/`
- Check SELinux/AppArmor if enabled
- Verify nginx user has access to files

## 🌐 Access Your Portfolio
After deployment, your portfolio will be available at:
- **Proxmox VM:** `http://136.243.155.166:8082/`
- **GitHub Pages:** `https://simonrenauld.github.io/`

## 📞 Support
If you encounter issues:
1. Check the deployment script output for error messages
2. Verify all files were transferred correctly
3. Ensure nginx is configured to serve from `/var/www/html/portfolio/`
4. Test with a simple HTML file first

## 🎉 Success Checklist
- [ ] Files transferred to Proxmox server
- [ ] Deployment script executed successfully
- [ ] Proper permissions set (www-data:www-data)
- [ ] Nginx restarted
- [ ] Portfolio accessible at http://136.243.155.166:8082/
- [ ] All interactive features working (dark mode, animations, etc.)

---
**Last Updated:** September 10, 2025
**Portfolio Version:** Enhanced with Creative UX/UI Improvements
