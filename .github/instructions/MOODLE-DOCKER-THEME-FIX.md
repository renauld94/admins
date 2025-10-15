# 🐳 Moodle Docker Container - Theme Installation Guide

**Problem:** The epic-course theme files are showing 404 errors because Moodle is running inside a Docker container on VM 9001, not directly on the VM.

**Date:** October 15, 2025  
**Status:** 🔴 Requires Manual VM Access

---

## 🔍 Current Situation

### What We Discovered

1. **VM 9001 Configuration:**
   - Running on vmbr1 network
   - IP Address: 10.0.0.104
   - Runs Docker containers for:
     - Moodle (port 8081 internally, proxied via 9001)
     - JupyterHub (port 8000)
     - ML API (port 8001)
     - MLflow (port 5000)
     - Bitbucket (port 7990)

2. **Current Setup:**
   - ✅ Files served by Proxmox nginx at `/var/www/moodle-assets/`
   - ✅ Accessible via `https://moodle.simondatalab.de/epic-course-*.css|js`
   - ❌ But Moodle HTML doesn't reference these files!
   - ❌ Files need to be inside the Moodle Docker container

3. **Why 404 Errors Occur:**
   - Moodle is requesting `/epic-course-theme.css`
   - But the file isn't in the Moodle document root
   - Nginx serves files BEFORE proxying to Moodle
   - Moodle container doesn't know about these files

---

## 🎯 Solution: Two Options

### Option A: Add Files via Moodle Admin Panel (EASIEST)

**Steps:**

1. **Login to Moodle Admin Panel:**
   - Go to: `https://moodle.simondatalab.de/`
   - Login as administrator

2. **Navigate to Additional HTML:**
   - Click: **Site administration**
   - Click: **Appearance**
   - Click: **Additional HTML**

3. **Add CSS and JS to HEAD:**

In the **"Within HEAD"** section, add:

```html
<!-- Epic Course Theme -->
<link rel="stylesheet" href="https://moodle.simondatalab.de/epic-course-theme.css">
<script src="https://moodle.simondatalab.de/epic-course-interactive.js"></script>
```

4. **Save Changes:**
   - Click **"Save changes"**
   - Clear Moodle cache: **Site administration > Development > Purge all caches**

5. **Test:**
   - Refresh Moodle page
   - Check browser console - 404 errors should be gone!

---

### Option B: Copy Files Inside Docker Container (ADVANCED)

**Prerequisites:**
- Console/terminal access to VM 9001
- Docker commands available

**Step-by-Step:**

#### 1. Access VM 9001 Console

**Via Proxmox Web UI:**
```
1. Go to: https://136.243.155.166:8006
2. Click on VM 9001 (moodle-lms-9001-1000104)
3. Click "Console" button
4. Login to VM
```

**Via SSH to Proxmox then console:**
```bash
ssh -p 2222 root@136.243.155.166
qm terminal 9001
# Login to VM
```

#### 2. Find Moodle Docker Container

Once inside VM 9001:

```bash
# List all running containers
docker ps

# Find Moodle container (look for 'moodle' in name or image)
MOODLE_CONTAINER=$(docker ps --filter name=moodle --format '{{.Names}}' | head -1)
echo "Moodle container: $MOODLE_CONTAINER"

# If not found, check all containers
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
```

#### 3. Copy Files to Container

```bash
# Files should already be in /tmp/ (uploaded by deployment script)
# If not, download them:
# curl -o /tmp/epic-course-theme.css https://moodle.simondatalab.de/epic-course-theme.css
# curl -o /tmp/epic-course-interactive.js https://moodle.simondatalab.de/epic-course-interactive.js

# Copy to Moodle container
docker cp /tmp/epic-course-theme.css $MOODLE_CONTAINER:/var/www/html/
docker cp /tmp/epic-course-interactive.js $MOODLE_CONTAINER:/var/www/html/
```

#### 4. Verify Files

```bash
# Check files are in container
docker exec $MOODLE_CONTAINER ls -lh /var/www/html/epic-course-*

# Should show:
# -rw-r--r-- 1 root root 14K ... epic-course-theme.css
# -rw-r--r-- 1 root root 16K ... epic-course-interactive.js
```

#### 5. Update Moodle Theme

**Method 1 - Via Moodle Admin (same as Option A above)**

**Method 2 - Edit theme file directly:**

```bash
# Access container shell
docker exec -it $MOODLE_CONTAINER bash

# Find theme directory
cd /var/www/html/theme/boost/layout/

# Edit columns2.php or header.php
nano columns2.php

# Add before </head> tag:
# <link rel="stylesheet" href="/epic-course-theme.css">
# <script src="/epic-course-interactive.js"></script>

# Save and exit (Ctrl+O, Enter, Ctrl+X)

# Set proper permissions
chown www-data:www-data /var/www/html/epic-course-*
chmod 644 /var/www/html/epic-course-*

# Exit container
exit
```

#### 6. Clear Moodle Cache

```bash
# Restart Moodle container to clear cache
docker restart $MOODLE_CONTAINER

# Wait 30 seconds
sleep 30

# Check container is running
docker ps | grep moodle
```

#### 7. Test

- Open browser: `https://moodle.simondatalab.de/`
- Press `Ctrl+Shift+R` to hard refresh
- Open DevTools (F12) > Network tab
- Look for `epic-course-theme.css` and `epic-course-interactive.js`
- Both should show **200 OK** status

---

## 📋 Automated Deployment Script

A helper script has been created at:
```
/home/simon/Learning-Management-System-Academy/deploy-moodle-theme-docker.sh
```

**Files uploaded to Proxmox:**
- `/tmp/epic-course-theme.css`
- `/tmp/epic-course-interactive.js`
- `/tmp/moodle-theme-install.sh` (helper script for VM)

**To use the helper script inside VM 9001:**

```bash
# After accessing VM console
bash /tmp/moodle-theme-install.sh
```

This script will:
1. Find the Moodle Docker container
2. Copy theme files into container
3. Verify files were copied
4. Provide next steps

---

## 🐛 Troubleshooting

### Can't Find Moodle Container

```bash
# List ALL containers (including stopped)
docker ps -a

# Check docker-compose services
cd / && find . -name "docker-compose.yml" 2>/dev/null
cat /path/to/docker-compose.yml

# If using docker-compose
docker-compose ps
```

### Files Not Accessible After Copy

```bash
# Check permissions inside container
docker exec $MOODLE_CONTAINER ls -la /var/www/html/

# Fix permissions
docker exec $MOODLE_CONTAINER chown -R www-data:www-data /var/www/html/epic-course-*
docker exec $MOODLE_CONTAINER chmod 644 /var/www/html/epic-course-*
```

### Still Getting 404 Errors

**Option 1: Verify file location**
```bash
# Check Moodle document root
docker exec $MOODLE_CONTAINER bash -c 'grep DocumentRoot /etc/apache2/sites-enabled/*' || \
docker exec $MOODLE_CONTAINER bash -c 'cat /etc/nginx/conf.d/default.conf | grep root'

# Adjust path if needed
```

**Option 2: Use absolute URL in Moodle admin**
```html
<!-- Use full URL instead of relative path -->
<link rel="stylesheet" href="https://moodle.simondatalab.de/epic-course-theme.css">
<script src="https://moodle.simondatalab.de/epic-course-interactive.js"></script>
```

This works because Proxmox nginx serves these files before proxying!

### Can't Access VM Console

**Alternative: Use Proxmox Web Interface**
1. Open: `https://136.243.155.166:8006`
2. Login with Proxmox credentials
3. Click VM 9001
4. Click "Console" or ">_ Console" button
5. Click "Start Now" if needed

---

## 📊 Architecture Diagram

```
Browser Request: https://moodle.simondatalab.de/
              ↓
         Proxmox Nginx (136.243.155.166:443)
              ↓
         SSL Termination
              ↓
    ┌─────────┴─────────┐
    ↓                   ↓
Serves                Proxies
/epic-course-*.css    everything else
from /var/www/        ↓
moodle-assets/    http://10.0.0.104:9001
    ↓                   ↓
Returns file       VM 9001 (Docker Host)
                        ↓
                   Docker Container
                   (Moodle Application)
                        ↓
                   Returns HTML
                   (may request /epic-course-*.css)
                        ↓
                   Back through proxy
                        ↓
                   Nginx serves file
```

**The Issue:**
- If Moodle HTML requests `/epic-course-theme.css` with a relative path
- It goes: Browser → Proxmox Nginx → VM Docker → Moodle PHP
- Moodle doesn't have the file in its document root
- Returns 404

**The Solution:**
- Either: Add files to Moodle container's document root
- Or: Use absolute URLs in Moodle theme configuration

---

## ✅ Recommended Approach

**For quickest resolution:**

1. ✅ **Use Option A (Moodle Admin Panel)**
   - No VM access needed
   - No Docker commands needed
   - Uses absolute URLs which are already served by Proxmox nginx
   - Takes 2 minutes

2. ⏰ **Later, if time permits:**
   - Access VM console
   - Copy files into Docker container
   - Update theme files directly
   - This ensures files are served even if Proxmox nginx changes

---

## 📝 Summary

**Current Status:**
- ✅ Files exist and are served by Proxmox nginx
- ✅ Files accessible at URLs
- ❌ Moodle doesn't know to request these files
- ❌ OR Moodle requests them but they're not in container

**Quick Fix (5 minutes):**
- Login to Moodle admin
- Add HTML snippet to "Additional HTML"
- Use absolute URLs: `https://moodle.simondatalab.de/epic-course-*.css|js`
- Clear cache
- **DONE!** ✅

**Proper Fix (30 minutes - requires VM access):**
- Access VM 9001 console
- Find Moodle Docker container
- Copy files into container
- Update theme configuration
- Restart container
- Test

---

**Priority:** 🔴 HIGH - Prevents theme from loading correctly

**Difficulty:**
- Quick fix: 🟢 EASY (no technical skills needed)
- Proper fix: 🟡 MODERATE (requires VM/Docker knowledge)

**Next Steps:** Choose your preferred option above and implement!

---

**Document Version:** 1.0  
**Created:** October 15, 2025  
**Author:** Simon Renauld  
**Location:** `.github/instructions/MOODLE-DOCKER-THEME-FIX.md`
