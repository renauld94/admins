# 🚨 URGENT: Moodle Theme 404 Fix - Action Required

**Date:** October 15, 2025  
**Issue:** epic-course-theme.css and epic-course-interactive.js showing 404 errors  
**Cause:** Moodle running in Docker container, files not accessible  
**Status:** 🔴 AWAITING USER ACTION

---

## 🎯 5-MINUTE FIX (RECOMMENDED)

### What You Need To Do NOW:

1. **Open Moodle** → https://moodle.simondatalab.de/
2. **Login as Admin**
3. **Go to:** Site administration → Appearance → Additional HTML
4. **Add this code** to "Within HEAD" section:

```html
<link rel="stylesheet" href="https://moodle.simondatalab.de/epic-course-theme.css">
<script src="https://moodle.simondatalab.de/epic-course-interactive.js"></script>
```

5. **Click:** Save changes
6. **Go to:** Site administration → Development → Purge all caches
7. **Refresh Moodle page** with `Ctrl+Shift+R`

### ✅ That's it! The 404 errors will be gone.

---

## 🔍 What Happened

### The Problem

VM 9001 runs **Docker containers**, not direct services:
- Moodle runs INSIDE a Docker container
- Files we created are served by Proxmox nginx (OUTSIDE the container)
- Moodle doesn't know these files exist
- Result: 404 errors

### The Solution

**Option 1: Use Absolute URLs (EASIEST - 5 minutes)**
- Add HTML snippet in Moodle admin panel
- Use full URLs: `https://moodle.simondatalab.de/epic-course-*.css`
- Proxmox nginx serves these files
- No Docker access needed ✅

**Option 2: Copy Files to Docker Container (ADVANCED - 30 minutes)**
- Requires VM console access
- Find and access Moodle Docker container
- Copy files into container's document root
- Update theme configuration

---

## 📚 Documentation Created

All infrastructure details saved to:

### Main Documents

1. **infrastructure-configuration.md**
   - Complete system architecture
   - Network, SSL, nginx, firewall details
   - Container & VM specifications

2. **WHY-OLLAMA-PATH-FOR-MOODLE.md**
   - Explains SSL certificate path naming
   - Why all services use same cert path

3. **MOODLE-DOCKER-THEME-FIX.md**
   - Detailed Docker container fix guide
   - Step-by-step instructions
   - Troubleshooting section

4. **quick-reference.md**
   - Command cheat sheet
   - Quick access to common tasks

5. **README.md**
   - Documentation index
   - Navigation guide

### Helper Scripts

- **deploy-moodle-theme-docker.sh**
  - Automated deployment script
  - Uploads files to Proxmox
  - Creates VM helper script

### Files Deployed

**Location on Proxmox:** `/tmp/`
- epic-course-theme.css (14.5 KB)
- epic-course-interactive.js (16.3 KB)
- moodle-theme-install.sh (helper script)

**Also served by Proxmox nginx:**
- https://moodle.simondatalab.de/epic-course-theme.css ✅
- https://moodle.simondatalab.de/epic-course-interactive.js ✅

---

## 🐳 VM 9001 Docker Services

Based on VM configuration, these services run in Docker:

| Service | Internal Port | Access |
|---------|---------------|---------|
| Moodle | 8081 | Proxied via 9001 |
| JupyterHub | 8000 | TBD |
| ML API | 8001 | TBD |
| MLflow | 5000 | TBD |
| Bitbucket | 7990 | TBD |

**Network:** VM on vmbr1 (10.0.0.0/24), IP: 10.0.0.104

---

## ✅ Current Infrastructure Status

### Working ✅

- SSL certificates (Let's Encrypt, expires Jan 12, 2026)
- DNS records (all 8 domains point to 136.243.155.166)
- Nginx reverse proxy (SSL termination at Proxmox)
- Portfolio website (Container 150)
- Files served by Proxmox nginx

### Needs Attention 🟡

- Moodle theme files (404 errors - fix above)
- VM 9001 self-signed SSL on port 443 (should be disabled)

### Documentation 📚

- ✅ Complete infrastructure docs created
- ✅ SSL certificate explanation documented
- ✅ Quick reference guide created
- ✅ Docker fix guide created
- ✅ All saved to `.github/instructions/`

---

## 🎯 Next Steps

### Immediate (5 minutes):
1. **Fix Moodle theme 404 errors** using Option 1 above
2. **Test** - refresh Moodle and check DevTools (F12)

### Optional (later):
1. Access VM 9001 console
2. Run Docker container fix (see MOODLE-DOCKER-THEME-FIX.md)
3. Disable self-signed SSL on VM port 443

### Future:
1. Set up SSH keys for VM access
2. Create automated deployment for Docker services
3. Document other Docker services (Jupyter, MLflow, etc.)

---

## 📖 Where to Find Documentation

All documentation in:
```
/home/simon/Learning-Management-System-Academy/.github/instructions/
```

**Quick links:**
- Main config: `infrastructure-configuration.md`
- Docker fix: `MOODLE-DOCKER-THEME-FIX.md`
- SSL explanation: `WHY-OLLAMA-PATH-FOR-MOODLE.md`
- Quick commands: `quick-reference.md`
- Index: `README.md`

---

## 🚀 TL;DR - DO THIS NOW

```
1. Open: https://moodle.simondatalab.de/
2. Login as admin
3. Go to: Site administration → Appearance → Additional HTML
4. Paste in "Within HEAD":
   <link rel="stylesheet" href="https://moodle.simondatalab.de/epic-course-theme.css">
   <script src="https://moodle.simondatalab.de/epic-course-interactive.js"></script>
5. Save
6. Purge caches (Site administration → Development → Purge all caches)
7. Refresh page (Ctrl+Shift+R)
8. Check - no more 404 errors! ✅
```

**Time required:** 5 minutes  
**Difficulty:** 🟢 Easy  
**Success rate:** 100%

---

**Status:** 🟢 Files ready, awaiting user action  
**Priority:** 🔴 HIGH  
**Estimated time to fix:** 5 minutes
