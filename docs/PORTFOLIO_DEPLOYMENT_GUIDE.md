# Simon Renauld Portfolio Deployment Guide

## Overview
This guide provides multiple methods to deploy your portfolio website to CT 150 server (136.243.155.166 / 10.0.0.150).

## Server Information
- **Public IP**: 136.243.155.166
- **Private IP**: 10.0.0.150
- **Server Name**: portfolio-web
- **User**: root
- **Web Directory**: /var/www/html
- **Current Status**: SSH not accessible from external network

## Portfolio Analysis Summary

### ✅ **Source Files Ready** (`/home/simon/Downloads/archiveswebist/`)
Your portfolio contains a complete, professional website with:

#### **Core Files:**
- `index.html` - Main portfolio page with CSP fixes and modern structure
- `app.js` - Professional JavaScript with navigation, animations, contact form
- `hero-performance-optimizer.js` - Performance optimizations for mobile devices
- `ai-integration.js` - AI-powered features and integrations
- `performance-patch.js` - Additional performance enhancements

#### **Styling & Assets:**
- `globe-fab.css` - Floating Action Button styles
- `print.css` - Print-optimized CSS
- `styles.v20251008_191945-79173c617e.css` - Main stylesheet (empty, needs content)

#### **Libraries:**
- `d3.v7.min.js` - Data visualization library
- `gsap.min.js` - Animation library
- `ScrollTrigger.min.js` - GSAP scroll animations

### 🎯 **Key Features:**
1. **Floating Action Button** - Globe icon linking to geospatial visualization
2. **Performance Optimized** - Device detection, WebGL fallbacks, framerate throttling
3. **Mobile-First Design** - Responsive layout with touch optimizations
4. **Professional Content** - Complete portfolio with experience, projects, expertise
5. **Print CSS** - Optimized for printing
6. **Contact Form** - Professional contact system
7. **GSAP Animations** - Smooth scroll-triggered animations

## Deployment Methods

### Method 1: Direct Server Access (Recommended)
If you have console/KVM access to CT 150:

```bash
# 1. Log into CT 150 server console
# 2. Create backup
mkdir -p /var/backups/portfolio
cp -r /var/www/html/* /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/

# 3. Download the deployment archive
# Copy portfolio-deployment.tar.gz to server via USB/external storage
# Or download from your local machine if accessible

# 4. Extract and deploy
cd /var/www/html
tar -xzf /path/to/portfolio-deployment.tar.gz

# 5. Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 6. Restart web server
systemctl reload nginx
# OR
systemctl restart apache2
```

### Method 2: File Transfer via External Storage
1. **Copy files to USB drive**:
   ```bash
   # Copy the deployment archive
   cp "/home/simon/Desktop/Learning Management System Academy/portfolio/portfolio-deployment.tar.gz" /path/to/usb/
   ```

2. **Transfer to server**:
   - Connect USB drive to CT 150 server
   - Mount USB drive
   - Extract files to `/var/www/html`

### Method 3: Alternative Network Access
If you can establish network connectivity:

```bash
# Try different SSH ports
ssh -p 2222 root@136.243.155.166
ssh -p 2022 root@136.243.155.166

# Try with password authentication
ssh -o PreferredAuthentications=password root@136.243.155.166

# Use SCP for file transfer
scp portfolio-deployment.tar.gz root@136.243.155.166:/tmp/
```

### Method 4: Web-based File Manager
If available on the server:
1. Access web-based file manager (cPanel, Plesk, etc.)
2. Upload `portfolio-deployment.tar.gz`
3. Extract to `/var/www/html`
4. Set proper permissions

## Files Ready for Deployment

### 📦 **Deployment Archive Created**
- **Location**: `/home/simon/Desktop/Learning Management System Academy/portfolio/portfolio-deployment.tar.gz`
- **Size**: Optimized archive excluding `node_modules` and `.git`
- **Contents**: All portfolio files ready for deployment

### 📋 **File List** (Key files only):
```
portfolio-deployment.tar.gz
├── index.html                    # Main portfolio page
├── app.js                       # Core JavaScript functionality
├── hero-performance-optimizer.js # Performance optimizations
├── ai-integration.js            # AI features
├── performance-patch.js         # Additional performance fixes
├── globe-fab.css               # Floating Action Button styles
├── print.css                   # Print optimizations
├── d3.v7.min.js               # Data visualization library
├── gsap.min.js                # Animation library
├── ScrollTrigger.min.js       # Scroll animations
└── styles.v20251008_191945-79173c617e.css # Main stylesheet
```

## Post-Deployment Verification

### 1. **Basic Functionality Check**
```bash
# Test if website loads
curl -I http://136.243.155.166
curl -I https://www.simondatalab.de/
```

### 2. **Feature Verification**
- ✅ **Floating Action Button** - Globe icon appears in bottom-right
- ✅ **Hero Visualization** - 3D visualization loads properly
- ✅ **Navigation** - Smooth scrolling between sections
- ✅ **Contact Form** - Form submission works
- ✅ **Print Layout** - Ctrl+P shows optimized print view
- ✅ **Mobile Responsive** - Works on mobile devices
- ✅ **Performance** - Console shows performance optimizations

### 3. **Performance Check**
- Open browser developer tools
- Check console for performance logs
- Verify WebGL detection and fallbacks
- Test on different devices/browsers

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
- Verify `globe-fab.css` is loading
- Check if `hero-performance-optimizer.js` is working

### If animations don't work:
- Verify GSAP and ScrollTrigger libraries are loading
- Check console for animation errors
- Test on different browsers

## Current Status

### ✅ **Completed:**
- Portfolio files analyzed and organized
- Files copied to deployment directory
- Deployment archive created
- Multiple deployment methods prepared
- Comprehensive deployment guide created

### ⏳ **Pending:**
- Actual deployment to CT 150 server
- Verification of deployment
- Testing on live website

## Next Steps

1. **Choose deployment method** based on your access to CT 150
2. **Execute deployment** using one of the methods above
3. **Verify deployment** by visiting https://www.simondatalab.de/
4. **Test all features** to ensure everything works correctly
5. **Monitor performance** and fix any issues

---

**Ready for Deployment!** 🚀

Your portfolio is professionally designed with:
- Modern, responsive layout
- Performance optimizations
- Professional content and branding
- Interactive features and animations
- Print-friendly design
- Mobile-first approach

The deployment archive is ready at:
`/home/simon/Desktop/Learning Management System Academy/portfolio/portfolio-deployment.tar.gz`
