# 🎯 Vietnamese Course Enhancement - Monitoring & Control Guide

## ⏱️ Runtime Information

**Total Duration:** 24 hours (automatically stops after completion)  
**Start Time:** When you run `./deploy_epic_enhancement.sh start`  
**Current Status:** Check with `./deploy_epic_enhancement.sh status`

---

## 🖥️ Monitoring Options (3 Ways)

### 1. **📊 LIVE TERMINAL DASHBOARD** (Recommended!)

**Start the dashboard:**
```bash
./monitor_dashboard.sh
```

**Features:**
- ✅ Real-time metrics updates (2-second refresh)
- ✅ Color-coded progress bars
- ✅ System resource monitoring (CPU, Memory, Disk)
- ✅ Live activity log
- ✅ Interactive controls (Restart, Stop, Pause, Resume)
- ✅ Current phase indicator
- ✅ Estimated time remaining

**Controls:**
- Press `R` → Restart agent
- Press `S` → Stop agent
- Press `P` → Pause/Resume
- Press `L` → View full logs
- Press `Q` → Quit dashboard (agent continues running)

**What you'll see:**
```
╔══════════════════════════════════════════════════════════════╗
║     🚀 VIETNAMESE COURSE EPIC ENHANCEMENT - LIVE DASHBOARD   ║
╚══════════════════════════════════════════════════════════════╝

🔥 STATUS: ACTIVE & ENHANCING
────────────────────────────────────────────────────────────────
⏱ Runtime:    02:15:30    → Remaining: 21:44:30
────────────────────────────────────────────────────────────────

📊 ENHANCEMENT METRICS
════════════════════════════════════════════════════════════════
• Pages Enhanced:      15 / 83     [████████░░░░░░░] 18%
• Widgets Deployed:    22 / 83     [███████████░░░░] 27%
• Media Generated:     45 / 200    [█████░░░░░░░░░░] 23%
• Features Added:      8 / 20      [████████░░░░░░░] 40%

★ Success Rate:        87.5%
⚠️ Errors:             3

════════════════════════════════════════════════════════════════

⚙️ CURRENT PHASE
────────────────────────────────────────────────────────────────
PHASE 2: AI WIDGET DEPLOYMENT
────────────────────────────────────────────────────────────────

🚀 SYSTEM RESOURCES
────────────────────────────────────────────────────────────────
• CPU:     15.3%    [███░░░░░░░░░░░░] 15%
• Memory:  42.1%    [█████████░░░░░░] 42%
• Disk:    67%      [████████████░░░] 67%
────────────────────────────────────────────────────────────────

ℹ️ RECENT ACTIVITY (Last 8 entries)
════════════════════════════════════════════════════════════════
✓ Successfully deployed widget to page 254
✓ Generated audio for 'Xin chào'
ℹ️ Processing page 255: Greetings and Introductions
✓ Widget injected into page 255
```

---

### 2. **🌐 WEB DASHBOARD** (Visual & Interactive)

**Open in browser:**
```bash
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course
python3 -m http.server 8090
```

Then open: http://localhost:8090/dashboard.html

**Features:**
- ✅ Beautiful visual interface with gradients
- ✅ Real-time progress bars
- ✅ Phase indicators (1-4)
- ✅ Live activity log with color coding
- ✅ Click buttons to control agent
- ✅ Auto-refreshes every 3 seconds
- ✅ Mobile-responsive design

**Perfect for:**
- Monitoring from another room
- Showing stakeholders progress
- Visual learners
- Taking screenshots for reports

---

### 3. **📋 COMMAND-LINE MONITORING** (Quick Checks)

**Check current status:**
```bash
./deploy_epic_enhancement.sh status
```

**Watch live logs:**
```bash
./deploy_epic_enhancement.sh monitor
# or
tail -f epic_enhancement.log
```

**Verify media files:**
```bash
./deploy_epic_enhancement.sh verify
```

**Check service status:**
```bash
sudo systemctl status vietnamese-epic-enhancement
```

**View last 50 log entries:**
```bash
tail -50 epic_enhancement.log
```

**Search for errors:**
```bash
grep ERROR epic_enhancement.log
```

**Count successes:**
```bash
grep "Successfully" epic_enhancement.log | wc -l
```

---

## 🎮 Control Commands

### Start/Stop/Restart
```bash
# Start the agent
./deploy_epic_enhancement.sh start

# Stop the agent
./deploy_epic_enhancement.sh stop

# Restart the agent (keeps progress)
./deploy_epic_enhancement.sh restart

# Check if running
./deploy_epic_enhancement.sh status
```

### Manual Control
```bash
# Start service directly
sudo systemctl start vietnamese-epic-enhancement

# Stop service
sudo systemctl stop vietnamese-epic-enhancement

# Restart service
sudo systemctl restart vietnamese-epic-enhancement

# Enable auto-start on boot
sudo systemctl enable vietnamese-epic-enhancement

# Disable auto-start
sudo systemctl disable vietnamese-epic-enhancement

# View service logs
sudo journalctl -u vietnamese-epic-enhancement -f
```

---

## 🔧 Re-Adjustment Options

### 1. **Pause and Resume**
```bash
# Pause (stop temporarily)
sudo systemctl stop vietnamese-epic-enhancement

# Resume later
sudo systemctl start vietnamese-epic-enhancement
```

**Use case:** Need to free up system resources for another task

### 2. **Modify Agent Configuration**

**Edit the agent parameters:**
```bash
nano epic_enhancement_agent.py
```

**Common adjustments:**
- Change Ollama model (line ~20): `MODEL = "qwen2.5-coder:32b-instruct-q4_K_M"`
- Adjust timeout (line ~25): `TIMEOUT = 60`
- Modify content length target (line ~100): `target_length = 2500`
- Change TTS speed (line ~300): `tts = gTTS(text, lang='vi', slow=False)`

**After editing:**
```bash
sudo systemctl restart vietnamese-epic-enhancement
```

### 3. **Skip Failed Pages**

If certain pages keep failing, you can blacklist them:

**Create a blacklist file:**
```bash
echo "46" >> blacklist.txt
echo "92" >> blacklist.txt
```

**Modify agent to skip them** (add to `epic_enhancement_agent.py`):
```python
# Load blacklist
with open('blacklist.txt', 'r') as f:
    blacklist = [int(line.strip()) for line in f]

# Skip blacklisted pages
if page_id in blacklist:
    logger.info(f"Skipping blacklisted page {page_id}")
    continue
```

### 4. **Adjust Rate Limiting**

If you're hitting API limits:

**Edit agent** (line ~150):
```python
# Add delay between API calls
import time
time.sleep(2)  # 2-second delay
```

### 5. **Change Priority**

Focus on specific improvements:

**Edit strategy** in `epic_enhancement_agent.py`:
```python
# Skip Phase 1 (content enhancement)
# async def phase_1_content_enhancement(self):
#     logger.info("Skipping Phase 1")
#     return

# Focus only on widgets (Phase 2)
# Comment out phases 1, 3, 4
```

---

## 📈 Progress Tracking

### Expected Timeline

| Phase | Duration | Tasks | Progress Check |
|-------|----------|-------|---------------|
| **Phase 1** | 8 hours | Content Enhancement (56 pages) | Check `Pages Enhanced` metric |
| **Phase 2** | 4 hours | Widget Deployment (83 pages) | Check `Widgets Deployed` metric |
| **Phase 3** | 6 hours | Media Generation (200+ files) | Check `Media Generated` metric |
| **Phase 4** | 6 hours | Advanced Features | Check `Features Added` metric |

### Milestones

**After 6 hours:** 
- ✅ ~30 pages enhanced
- ✅ Content quality improved
- ✅ First batch of media generated

**After 12 hours:**
- ✅ All pages enhanced
- ✅ 50% widgets deployed
- ✅ 100+ audio files created

**After 18 hours:**
- ✅ All widgets deployed
- ✅ Most media files generated
- ✅ Advanced features starting

**After 24 hours:**
- ✅ Complete transformation
- ✅ 200+ audio files
- ✅ 7 flashcard decks
- ✅ All features implemented

---

## 🚨 Troubleshooting

### Agent Stopped Unexpectedly

**Check why it stopped:**
```bash
sudo journalctl -u vietnamese-epic-enhancement -n 50
```

**Common issues:**
1. **Ollama API not responding** → Check `curl http://localhost:11434/api/version`
2. **SSH connection lost** → Verify `ssh moodle-vm9001 echo test`
3. **Out of memory** → Check `free -h`
4. **Python error** → Check `tail -100 epic_enhancement.log`

**Restart with fix:**
```bash
./deploy_epic_enhancement.sh restart
```

### Low Success Rate

**Check error patterns:**
```bash
grep ERROR epic_enhancement.log | cut -d':' -f3- | sort | uniq -c | sort -rn
```

**Common fixes:**
- Ollama timeout → Increase timeout in agent
- Network issues → Check SSH tunnel stability
- Invalid content → Review page structure
- API rate limit → Add delays between calls

### High Error Count

**Acceptable error rate:** < 10% (< 8 errors per 83 pages)

**If errors > 20:**
1. Check Ollama health: `curl http://localhost:11434/api/version`
2. Verify Moodle access: `ssh moodle-vm9001 "docker ps"`
3. Review error types: `grep ERROR epic_enhancement.log | tail -20`
4. Consider restarting: `./deploy_epic_enhancement.sh restart`

---

## 📊 Metrics Explained

### Success Rate Formula
```
Success Rate = (Successful Operations / Total Operations) × 100
```

**Good:** > 85%  
**Acceptable:** 70-85%  
**Needs Attention:** < 70%

### Time Estimates

**Based on progress:**
```
Estimated Completion = Start Time + (24 hours × (1 - Progress%))
```

**Example:**
- Started: 10:00 AM
- Current: 2:00 PM (4 hours elapsed)
- Progress: 25% completed
- Estimated end: 10:00 AM next day (20 hours remaining)

---

## 🎯 Best Practices

### 1. **Monitor Regularly** (Every 2-3 hours)
```bash
./monitor_dashboard.sh
```

### 2. **Check Logs for Patterns**
```bash
# Look for repeated errors
grep ERROR epic_enhancement.log | cut -d':' -f4- | sort | uniq -c | sort -rn | head -10
```

### 3. **Verify Media Files**
```bash
ls -lh generated/professional/ | wc -l
```

### 4. **Test Sample Page**
Visit a recently enhanced page in Moodle to verify:
- Content quality improved
- AI widget present and functional
- Pronunciation checker working
- Audio files playable

### 5. **Backup Before Major Changes**
```bash
# Backup current state
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz epic_enhancement_agent.py epic_enhancement.log
```

---

## 🆘 Emergency Controls

### Stop Everything Immediately
```bash
sudo systemctl stop vietnamese-epic-enhancement
sudo pkill -f epic_enhancement_agent.py
```

### Rollback Changes (If Needed)
```bash
# This would require manual database queries
ssh moodle-vm9001 "sudo docker exec moodle-databricks-fresh php /bitnami/moodle/admin/cli/purge_caches.php"
```

### Full Reset and Restart
```bash
sudo systemctl stop vietnamese-epic-enhancement
rm -f epic_enhancement.log
./deploy_epic_enhancement.sh start
```

---

## 📞 Quick Reference

| Task | Command |
|------|---------|
| Start agent | `./deploy_epic_enhancement.sh start` |
| Stop agent | `./deploy_epic_enhancement.sh stop` |
| Check status | `./deploy_epic_enhancement.sh status` |
| Live dashboard | `./monitor_dashboard.sh` |
| View logs | `tail -f epic_enhancement.log` |
| Restart agent | `./deploy_epic_enhancement.sh restart` |
| Verify media | `./deploy_epic_enhancement.sh verify` |
| Web dashboard | Open `dashboard.html` in browser |

---

## 🎉 Success Indicators

You'll know it's working well when you see:

✅ **Success rate > 85%**  
✅ **Errors < 10**  
✅ **Steady progress every hour**  
✅ **Log shows "Successfully" messages**  
✅ **Media files accumulating**  
✅ **System resources stable (CPU < 80%)**

---

**Made with ❤️ for epic Vietnamese learning! 🇻🇳**
