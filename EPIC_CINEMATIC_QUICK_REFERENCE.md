# Epic Cinematic Agent - Quick Reference

## Status: ✅ ACTIVE & RUNNING

**Deployment**: Complete  
**Server**: VM 159 (ubuntuai-1000110, IP: 10.0.0.110)  
**Service**: epic-cinematic-http.service (systemd)  
**Port**: 8000  
**Animation**: 105-second neural-to-cosmic loop  

---

## 🎯 Quick Access

### View Animation
```
Direct:  http://10.0.0.110:8000
Tunnel:  ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 -L 8000:localhost:8000
         Then: http://localhost:8000
```

### Check Status
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "sudo systemctl status epic-cinematic-http.service"
```

### View Logs
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "sudo journalctl -u epic-cinematic-http.service -f"
```

### Regenerate Files
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 \
    "cd /home/simonadmin/epic-cinematic-agent && python3 epic_cinematic_agent.py"
```

---

## 📍 Locations

| Component | Path |
|-----------|------|
| Agent Script | `/home/simonadmin/epic-cinematic-agent/epic_cinematic_agent.py` |
| HTTP Output | `/home/simonadmin/epic-cinematic-output/` |
| Service | `/etc/systemd/system/epic-cinematic-http.service` |
| Logs | `/tmp/epic_cinematic_vm159.log` |

---

## 🔄 Service Commands

```bash
# SSH to VM 159 first:
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110

# Then:
sudo systemctl status epic-cinematic-http.service   # Status
sudo systemctl restart epic-cinematic-http.service  # Restart
sudo systemctl stop epic-cinematic-http.service     # Stop
sudo systemctl start epic-cinematic-http.service    # Start
sudo journalctl -u epic-cinematic-http.service -f   # Live logs
```

---

## 🎬 What's Animated

**Infrastructure Visualization**:
- Origin: Ho Chi Minh City (0x00d4ff cyan)
- Regional Hubs: Singapore, Bangkok, Jakarta, KL (0x8b5cf6 purple)
- Global Nodes: Berlin, SF, Tel Aviv, Seoul, Sydney (0xff6b35 orange)
- Satellites: VM 159, VM 9001, ML Training, GeoServer, Network (orbiting)
- Departments: Dev, DataSci, Design, Ops, NetSci, ML, GeoSpatial, Learning

**Camera Path**: 105-second cinematic orbit with smooth transitions

**Effects**: Bloom, particle effects, fog, shadow mapping, film grain

---

## 📊 Tech Stack

| Component | Technology |
|-----------|-------------|
| Backend | Python 3.12.3 |
| HTTP Server | Python http.server |
| Frontend | Three.js 0.160.0 (CDN) |
| Graphics | WebGL 2.0 |
| Animation | 60 FPS target, 105s loop |
| Responsive | Desktop, Tablet, Mobile |

---

## 🐛 Troubleshooting

**Not accessible?**
```bash
# Test connectivity
curl -I http://10.0.0.110:8000/

# Check if port is open
ss -tlnp | grep 8000
```

**Service crashed?**
```bash
# Check what happened
sudo journalctl -u epic-cinematic-http.service -n 30

# Restart
sudo systemctl restart epic-cinematic-http.service
```

**Files not generating?**
```bash
# Check agent directly
cd /home/simonadmin/epic-cinematic-agent
python3 epic_cinematic_agent.py

# Check for errors
cat /tmp/epic_cinematic_vm159.log | tail -20
```

---

## 📈 Performance

- Memory: ~200 MB
- CPU: <1% idle, ~5% during generation
- File Size: 12 KB total
- Generation Time: <100ms
- Network Bandwidth: ~5 KB/s per client

---

## 🔐 URLs & Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/` | Directory listing |
| `/index.html` | Main animation page |
| `/main.js` | Three.js visualization engine |
| `/package.json` | Project metadata |
| `/README.md` | Documentation |

---

## 💡 Key Features

✅ Autonomous agent generates new animations  
✅ 105-second seamless loop  
✅ Real-time FPS display  
✅ Geographic coordinates for all nodes  
✅ Cinematic camera paths  
✅ Post-processing effects  
✅ Mobile responsive  
✅ Zero external dependencies (except CDN)  
✅ Auto-restart on failure  
✅ 48-hour max runtime (prevents resource exhaustion)  

---

**Last Updated**: 2025-11-06 15:12 UTC+7  
**Status**: ✅ Production Ready  
**Support**: Check logs, verify service status, regenerate files as needed
