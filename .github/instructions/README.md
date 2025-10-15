# 📚 Infrastructure Documentation Index

**Simon Data Lab - Complete Documentation Suite**  
**Last Updated:** October 15, 2025

---

## 📖 Documentation Files

### 🏗️ Core Infrastructure

**[infrastructure-configuration.md](./infrastructure-configuration.md)**
- Complete system architecture
- Network topology and IP mappings
- SSL/TLS certificate details
- Nginx configurations (all services)
- Firewall & NAT rules
- Container & VM specifications
- DNS configuration
- Service ports and mappings
- Backup & recovery procedures

**Purpose:** Comprehensive reference for all infrastructure components

---

### 🔑 Quick Reference

**[quick-reference.md](./quick-reference.md)**
- SSH access commands
- Common management tasks
- IP address quick lookup
- Nginx reload/restart commands
- IPTables management
- Certificate operations
- Container/VM control
- Health check scripts
- Troubleshooting one-liners

**Purpose:** Fast access to frequently used commands

---

### ❓ SSL Certificate Path Explanation

**[WHY-OLLAMA-PATH-FOR-MOODLE.md](./WHY-OLLAMA-PATH-FOR-MOODLE.md)**
- Why Moodle uses `/etc/letsencrypt/live/ollama.simondatalab.de/`
- Multi-domain certificate explanation
- Subject Alternative Names (SANs) details
- How TLS/SSL validation works
- Verification commands
- Optional renaming procedure

**Purpose:** Answers "Why does the certificate path say 'ollama' when serving Moodle?"

---

## 🗺️ Quick Navigation

### By Topic

#### SSL/TLS Certificates
1. [SSL Details](./infrastructure-configuration.md#ssltls-certificates) - Full certificate documentation
2. [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md) - Path explanation
3. [Certificate Commands](./quick-reference.md#-certificate-management) - Quick commands

#### Nginx Configuration
1. [All Configs](./infrastructure-configuration.md#nginx-configuration) - Complete nginx setup
2. [Nginx Management](./quick-reference.md#️-nginx-management) - Common operations
3. [Moodle Config](./infrastructure-configuration.md#2-moodle-lms) - Moodle-specific

#### Network & Firewall
1. [Network Architecture](./infrastructure-configuration.md#network-architecture) - Network diagram
2. [IP Addresses](./quick-reference.md#-ip-addresses) - Quick IP lookup
3. [Firewall Rules](./infrastructure-configuration.md#firewall--nat-rules) - IPTables details
4. [NAT Rules](./quick-reference.md#-iptables-quick-commands) - NAT management

#### Containers & VMs
1. [Container 150 (Portfolio)](./infrastructure-configuration.md#container-150---portfolio-web-server)
2. [VM 9001 (Moodle)](./infrastructure-configuration.md#vm-9001---moodle-lms-server)
3. [Management Commands](./quick-reference.md#-container--vm-management)

#### DNS Configuration
1. [DNS Records](./infrastructure-configuration.md#dns-configuration) - Cloudflare setup
2. [DNS Commands](./infrastructure-configuration.md#dns-propagation-check) - Verification

---

## 🎯 Common Tasks

### Setting Up a New Service

**Read:**
1. [Network Architecture](./infrastructure-configuration.md#network-architecture) - Understand network layout
2. [Nginx Configuration](./infrastructure-configuration.md#nginx-configuration) - See example configs
3. [SSL Certificates](./WHY-OLLAMA-PATH-FOR-MOODLE.md) - Understand certificate usage

**Execute:**
1. Create nginx server block
2. Point to existing certificate (same path as others)
3. Add DNS record in Cloudflare
4. Test with `nginx -t`
5. Reload nginx

### Troubleshooting SSL Issues

**Read:**
1. [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md) - Understand certificate structure
2. [SSL Details](./infrastructure-configuration.md#ssltls-certificates) - Check current setup

**Execute:**
```bash
# Check certificate validity
certbot certificates

# Verify SANs include your domain
openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -text | grep -A 10 "Subject Alternative Name"

# Test SSL connection
echo | openssl s_client -connect yourdomain.simondatalab.de:443 -servername yourdomain.simondatalab.de 2>/dev/null | grep "Verify"
```

### Updating Nginx Configuration

**Read:**
1. [Nginx Configuration](./infrastructure-configuration.md#nginx-configuration) - See current configs
2. [Quick Reference](./quick-reference.md#-update-workflow) - Update procedures

**Execute:**
```bash
# 1. Backup
cp /etc/nginx/sites-enabled/config.conf /etc/nginx/sites-enabled/config.conf.backup-$(date +%Y%m%d-%H%M%S)

# 2. Edit
nano /etc/nginx/sites-enabled/config.conf

# 3. Test
nginx -t

# 4. Apply
systemctl reload nginx
```

### Adding a Domain to Certificate

**Read:**
1. [SSL Certificate Details](./infrastructure-configuration.md#certificate-details) - Current setup
2. [Certbot Configuration](./infrastructure-configuration.md#certbot-configuration) - Renewal config

**Execute:**
```bash
# Request new certificate with additional domain
certbot certonly --dns-cloudflare \
  --cert-name ollama.simondatalab.de \
  -d simondatalab.de \
  -d www.simondatalab.de \
  -d moodle.simondatalab.de \
  -d grafana.simondatalab.de \
  -d ollama.simondatalab.de \
  -d mlflow.simondatalab.de \
  -d booklore.simondatalab.de \
  -d geoneuralviz.simondatalab.de \
  -d newdomain.simondatalab.de

# Reload nginx
systemctl reload nginx
```

---

## 🔍 Finding Information

### "I need to..."

| Task | Document | Section |
|------|----------|---------|
| Find IP addresses | [Quick Reference](./quick-reference.md) | IP Addresses |
| Understand SSL path | [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md) | The Explanation |
| View nginx configs | [Infrastructure](./infrastructure-configuration.md) | Nginx Configuration |
| Check firewall rules | [Infrastructure](./infrastructure-configuration.md) | Firewall & NAT Rules |
| Restart a service | [Quick Reference](./quick-reference.md) | Container & VM Management |
| Update DNS | [Infrastructure](./infrastructure-configuration.md) | DNS Configuration |
| Troubleshoot SSL | [Quick Reference](./quick-reference.md) | Troubleshooting Commands |
| Backup configs | [Infrastructure](./infrastructure-configuration.md) | Backup & Recovery |

---

## 📊 Infrastructure Overview

### Current Setup (October 15, 2025)

**Server:** Proxmox VE 6.8.12-14-pve @ 136.243.155.166:2222  
**SSL Provider:** Let's Encrypt (auto-renewal enabled)  
**DNS Provider:** Cloudflare (DNS-only mode)  
**Reverse Proxy:** Nginx (SSL termination at Proxmox level)

**Active Services:**

| Service | Domain | Container/VM | Port |
|---------|--------|--------------|------|
| Portfolio | www.simondatalab.de | CT 150 | 80 |
| Moodle | moodle.simondatalab.de | VM 9001 | 9001 |
| Jellyfin | - | CT 103 | 8096 |

**SSL Certificate:**
- **Path:** `/etc/letsencrypt/live/ollama.simondatalab.de/`
- **Covers:** 8 domains (multi-domain SAN certificate)
- **Expires:** January 12, 2026
- **Status:** ✅ Valid & Auto-renewing

---

## 🎓 Learning Path

### New to Infrastructure Management?

**Start here:**
1. Read [Quick Reference](./quick-reference.md) - Get familiar with common commands
2. Read [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md) - Understand SSL setup
3. Browse [Infrastructure](./infrastructure-configuration.md) - Deep dive when needed

### Experienced System Administrator?

**Jump to:**
1. [Infrastructure Configuration](./infrastructure-configuration.md) - Complete technical specs
2. [Quick Reference](./quick-reference.md) - Bookmark for daily use
3. [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md) - Understand design decisions

---

## 🔄 Related Documentation

### In `/home/simon/Learning-Management-System-Academy/`

- **MOODLE_THEME_DEPLOYMENT.md** - Moodle theme customization
- **SIMONDATALAB_REDIRECT_FIX_COMPLETE_DOCUMENTATION.md** - SSL/redirect fixes history
- **PORTFOLIO_FIX_SUMMARY.md** - Portfolio deployment details
- **DEPLOYMENT_STATUS.md** - Overall deployment status

### External Resources

- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Cloudflare API](https://api.cloudflare.com/)

---

## 📞 Support & Maintenance

### Regular Maintenance Schedule

**Daily (Automated):**
- Certbot renewal check (via systemd timer)
- Log rotation

**Weekly:**
- Review nginx error logs
- Check disk space
- Verify backup completion

**Monthly:**
- Test certificate renewal: `certbot renew --dry-run`
- Update system packages
- Review firewall rules

**Quarterly:**
- Full system backup
- Security audit
- Update documentation

### Emergency Procedures

**Service Down:**
1. Check [Quick Reference - Troubleshooting](./quick-reference.md#-common-issues--solutions)
2. Review [Infrastructure - Troubleshooting Commands](./infrastructure-configuration.md#-troubleshooting-commands)
3. Check recent changes in git history

**SSL Certificate Issues:**
1. Read [Why Ollama Path?](./WHY-OLLAMA-PATH-FOR-MOODLE.md)
2. Verify SANs include your domain
3. Force renewal if needed: `certbot renew --force-renewal`

**Configuration Rollback:**
```bash
# List backups
ls -lt /etc/nginx/sites-enabled/*.backup-*

# Restore latest
cp /etc/nginx/sites-enabled/config.conf.backup-YYYYMMDD-HHMMSS /etc/nginx/sites-enabled/config.conf

# Test and reload
nginx -t && systemctl reload nginx
```

---

## ✅ Documentation Standards

### When to Update

**Update immediately after:**
- Adding/removing services
- Changing nginx configurations
- Modifying firewall rules
- SSL certificate changes
- IP address changes
- DNS record updates

**Files to update:**
- [infrastructure-configuration.md](./infrastructure-configuration.md) - Full details
- [quick-reference.md](./quick-reference.md) - Quick commands
- This index (if new document added)

### Version Control

**All documentation is version controlled:**
```bash
cd /home/simon/Learning-Management-System-Academy
git add .github/instructions/
git commit -m "docs: Update infrastructure documentation"
git push
```

---

## 🏆 Best Practices

1. **Always backup before changes**
   ```bash
   cp config.conf config.conf.backup-$(date +%Y%m%d-%H%M%S)
   ```

2. **Test nginx configs before reload**
   ```bash
   nginx -t && systemctl reload nginx
   ```

3. **Document as you go**
   - Update this documentation immediately after changes
   - Include the "why" not just the "what"

4. **Use consistent naming**
   - Backup files: `name.backup-YYYYMMDD-HHMMSS`
   - Configs: Descriptive names with service domain

5. **Keep it simple**
   - One multi-domain certificate > many single-domain certs
   - DNS-only mode > Cloudflare proxy (for our use case)
   - Proxmox SSL termination > individual service SSL

---

**Index Version:** 1.0.0  
**Created:** October 15, 2025  
**Maintainer:** Simon Renauld  
**Repository:** renauld94/admins (master branch)
