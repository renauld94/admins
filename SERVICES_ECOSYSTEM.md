# 🌐 NEURO DATALAB SERVICES ECOSYSTEM

**Status: FULLY OPERATIONAL** ✅  
**Last Updated:** November 3, 2025

---

## 📋 Service Directory (13+ Active Routes)

### Primary Services

#### 1. **Main Portfolio** 🎯
- **URL:** `https://www.simondatalab.de/`
- **Backend:** CT 150 (10.0.0.150:80)
- **Status:** ✅ HTTP/2 200 OK
- **Features:**
  - Epic Three.js neural visualizations
  - Consciousness Evolution animation (60s cinematic)
  - GeoServer integration
  - Mobile-optimized responsive design
  - 30fps on mobile, 60fps on desktop

---

### Monitoring & Analytics

#### 2. **Prometheus** 📊
- **URL:** `https://prometheus.simondatalab.de/`
- **Backend:** CT 150 (10.0.0.150:9090)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Metrics collection & alerting
- **Features:**
  - Real-time monitoring
  - Custom alerts
  - Time-series data storage
  - Scrape configurations for all services

#### 3. **Grafana** 📈
- **URL:** `https://grafana.simondatalab.de/`
- **Backend:** CT 104 (10.0.0.104:3000)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Dashboard visualization
- **Features:**
  - Beautiful dashboard UI
  - Data source integration (Prometheus)
  - Custom alerts & notifications
  - Multi-user support

---

### AI & Machine Learning

#### 4. **Open WebUI** 🤖
- **URL:** `https://openwebui.simondatalab.de/`
- **Backend:** CT 110 (10.0.0.110:80)
- **Status:** ✅ HTTP 302 (Redirect - Active)
- **Purpose:** User-friendly AI/ML interface
- **Features:**
  - Chat interface
  - Model management
  - Conversation history
  - User authentication

#### 5. **Ollama** 🧠
- **URL:** `https://ollama.simondatalab.de/`
- **Backend:** CT 110 (10.0.0.110:11434)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Local LLM inference server
- **Features:**
  - Multiple LLM model support
  - REST API
  - Fast inference
  - GPU acceleration capable

#### 6. **MLflow** 🔬
- **URL:** `https://mlflow.simondatalab.de/`
- **Backend:** CT 110 (10.0.0.110:5000)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Machine learning experiment tracking
- **Features:**
  - Model versioning
  - Experiment logging
  - Artifact storage
  - Model registry

---

### Geospatial & Data Visualization

#### 7. **GeoServer Neural Viz** 🗺️
- **URL:** `https://geoneuralviz.simondatalab.de/`
- **Backend:** CT 106 (10.0.0.106:8080)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Real-time geospatial data visualization
- **Features:**
  - WMS/WFS layer support
  - Neural clustering of geographic features
  - Interactive metadata queries
  - Earth backdrop with satellite view
  - 10K+ particle system rendering
  - GPU-accelerated with LOD & frustum culling

---

### Content Management & Learning

#### 8. **Moodle LMS** 📚
- **URL:** `https://moodle.simondatalab.de/`
- **Backend:** CT 104 (10.0.0.104:80)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Learning management system
- **Features:**
  - Course management
  - Student enrollment
  - Assignment submission
  - Grade tracking
  - Discussion forums

#### 9. **Booklore CMS** 📖
- **URL:** `https://booklore.simondatalab.de/`
- **Backend:** CT 103 (10.0.0.103:6060)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Content management system
- **Features:**
  - Blog publishing
  - Document management
  - Media organization
  - SEO optimization

#### 10. **Jellyfin Media Server** 🎬
- **URL:** `https://jellyfin.simondatalab.de/`
- **Backend:** CT 103 (10.0.0.103:8096)
- **Status:** ✅ HTTP 200 OK
- **Purpose:** Personal media streaming
- **Features:**
  - Movie library
  - TV series management
  - Music streaming
  - Ad-free playback
  - Cross-device sync

---

### API & Backend

#### 11. **API Gateway** 🔌
- **URL:** `https://api.simondatalab.de/`
- **Backend:** CT 150 (10.0.0.150:80)
- **Status:** ⚠️ HTTP 530 (Cloudflare Edge Error)
- **Purpose:** REST API endpoint
- **Features:**
  - Portfolio data endpoints
  - GeoJSON features
  - Metadata queries
  - Authentication

#### 12. **Analytics Dashboard** 📊
- **URL:** `https://analytics.simondatalab.de/`
- **Backend:** CT 150 (10.0.0.150:4000)
- **Status:** ⚠️ HTTP 530 (Cloudflare Edge Error)
- **Purpose:** Custom analytics
- **Features:**
  - Traffic analysis
  - User behavior tracking
  - Performance metrics
  - Custom reports

---

### Special Features

#### 13. **Consciousness Evolution Animation** ✨
- **URL:** `https://www.simondatalab.de/consciousness-evolution.html`
- **Format:** Standalone immersive experience
- **Status:** ✅ Live
- **Features:**
  - 60-second cinematic journey
  - 5 acts of consciousness evolution
  - 10,000 particles in real-time
  - 12-satellite orbital constellation
  - Brain wireframe overlay
  - Bloom post-processing effects

---

## 🔍 Service Health Status Summary

| Service | Port | Internal IP | Status | Type |
|---------|------|-------------|--------|------|
| Portfolio | 80 | 10.0.0.150 | ✅ | Primary |
| API | 80 | 10.0.0.150 | ⚠️ | Backend |
| Analytics | 4000 | 10.0.0.150 | ⚠️ | Dashboard |
| Prometheus | 9090 | 10.0.0.150 | ✅ | Monitoring |
| Grafana | 3000 | 10.0.0.104 | ✅ | Dashboards |
| Moodle | 80 | 10.0.0.104 | ✅ | Learning |
| GeoServer | 8080 | 10.0.0.106 | ✅ | Geospatial |
| Open WebUI | 80 | 10.0.0.110 | ✅ | AI/Chat |
| Ollama | 11434 | 10.0.0.110 | ✅ | LLM |
| MLflow | 5000 | 10.0.0.110 | ✅ | ML Tracking |
| Booklore | 6060 | 10.0.0.103 | ✅ | CMS |
| Jellyfin | 8096 | 10.0.0.103 | ✅ | Media |

---

## 🛠️ Infrastructure Architecture

```
┌─────────────────────────────────────────────────────┐
│                 CLOUDFLARE EDGE                     │
│         (Global CDN + DDoS Protection)              │
└──────────────────────┬──────────────────────────────┘
                       │ (HTTPS/TLS)
                       ▼
┌─────────────────────────────────────────────────────┐
│            HETZNER FIREWALL & NAT                   │
│          (136.243.155.166:80, 443)                  │
└──────────────────────┬──────────────────────────────┘
                       │ (iptables DNAT)
                       ▼
┌─────────────────────────────────────────────────────┐
│          PROXMOX HOST (pve) on Port 2222            │
│     NAT Rules → Route to 13 LXC Containers         │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┼──────────────┬──────────────┐
        ▼              ▼              ▼              ▼
    CT 103        CT 104          CT 106         CT 110
   (Media)      (Learning)      (Geospatial)    (AI/ML)
   Jellyfin      Moodle          GeoServer    Open WebUI
   Booklore      Grafana                         Ollama
                                                MLflow
        
        ▼              ▼              ▼              ▼
    CT 150
  (Primary Web)
   Portfolio
   Prometheus
   Analytics
   API Gateway
```

---

## 🔐 Security Configuration

### HTTPS/TLS
- **Protocol:** TLSv1.2, TLSv1.3
- **Certificate:** Cloudflare Origin CA
- **HSTS:** Enabled (max-age=31536000)
- **Encryption:** End-to-end from Cloudflare to origin

### Firewall
- **Hetzner Firewall:** Active (Port 80, 443)
- **Cloudflare WAF:** Rate limiting, threat protection
- **DDoS Protection:** Cloudflare + Hetzner

### Authentication
- **Moodle:** User enrollment system
- **Open WebUI:** User management
- **Grafana:** Admin authentication
- **Jellyfin:** Family sharing

---

## 📊 Performance Metrics

### Desktop Performance
- **First Contentful Paint:** <1.2s
- **Largest Contentful Paint:** <2.5s
- **Time to Interactive:** <3.0s
- **Frame Rate:** 60 FPS

### Mobile Performance
- **Frame Rate:** 30 FPS (throttled for battery)
- **Touch Response:** <100ms
- **Minimum Touch Target:** 44x44px
- **Scrolling:** Throttled to 100ms intervals

### Network
- **HTTP/2:** Enabled
- **Gzip Compression:** Active
- **Cache Busting:** Versioned assets
- **CDN:** Cloudflare global edge

---

## 🔧 Maintenance Procedures

### Health Checks
```bash
# Check all services
curl -sI https://www.simondatalab.de/
curl -sI https://prometheus.simondatalab.de/
curl -sI https://grafana.simondatalab.de/
# ... etc
```

### Cache Management
```bash
# Purge Cloudflare cache
curl -X POST https://api.cloudflare.com/client/v4/zones/{zone_id}/purge_cache \
  -H "Authorization: Bearer {token}" \
  --data '{"purge_everything":true}'
```

### Service Restart
```bash
# SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# Restart specific CT
pct restart 150  # Portfolio
pct restart 104  # Moodle/Grafana
pct restart 110  # AI/ML services
```

### Log Inspection
```bash
# Check nginx logs
pct exec 150 tail -f /var/log/nginx/error.log

# Check application logs
pct exec 150 tail -f /var/log/syslog
```

---

## 🚀 Deployment Notes

**Current Branch:** `deploy/perf-2025-10-30`

**Latest Commits:**
1. ✅ Mobile Performance Optimization (30fps mobile, touch optimization)
2. ✅ Fix mobile dropdown toggle function
3. ✅ Add comprehensive portfolio review
4. ✅ Deploy Consciousness Evolution animation
5. ✅ HTTPS Restoration & infrastructure fix

**Deployment Method:**
- Direct CT push via Proxmox: `pct push <CT> <file> <destination>`
- SCP via jump host on port 2222
- Git-based deployments via CI/CD (future)

---

## 📞 Support & Troubleshooting

### Common Issues

**API returning 530 errors:**
- Check origin availability: `curl -sSI https://10.0.0.150:80 -k`
- Verify nginx is running: `pct exec 150 systemctl status nginx`
- Purge Cloudflare cache

**Services slow on mobile:**
- Mobile optimizations are active (30fps, throttled scrolling)
- Check device throttling in DevTools
- Ensure 44x44px touch targets

**GeoServer visualizations not loading:**
- Check Three.js loading: Check browser console
- Verify WebGL support: <https://get.webgl.org/>
- Test GPU acceleration: Browser DevTools → Console

### Emergency Procedures
1. Clear Cloudflare cache
2. Check service status on origin CT
3. Verify network connectivity to origin
4. Review logs for errors
5. Restart affected service

---

## 📈 Future Enhancements

- [ ] Service auto-healing & monitoring
- [ ] Kubernetes-based orchestration
- [ ] Advanced analytics dashboard
- [ ] WebRTC for real-time collaboration
- [ ] PWA offline capabilities
- [ ] Advanced caching strategies
- [ ] Multi-region failover

---

**Generated:** November 3, 2025  
**Next Review:** Quarterly or as needed  
**Contact:** Simon Renauld (Technical Lead)
