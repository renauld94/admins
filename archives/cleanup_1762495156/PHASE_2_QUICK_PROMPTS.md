# 🎯 PHASE 2: WebSocket Prompt Copy-Paste
## Ready to use with Continue IDE (Ctrl+I)

---

## PROMPT 1: WebSocket Real-Time Stats
**Position**: After `</script>` tag in index.html (around line 350+)  
**Action**: Press **Ctrl+I**, paste below, press Enter

```
TASK: Add WebSocket real-time data updates to statistics cards

REQUIREMENTS:
1. Create WebSocket client connecting to ws://localhost:8000/ws/realtime
2. Update these stats in real-time WITHOUT page reload:
   - #activeNodes (current: 25)
   - #connections (current: 103)  
   - #throughput (current: 595TB)
   - #uptime (current: 99.9%)
3. Add smooth counter animation for stat value changes
4. Show connection status indicator (green dot = connected, red = disconnected)
5. Reconnect automatically if connection drops
6. Keep existing glassmorphism styling

CODE PATTERN:
- Use requestAnimationFrame for smooth number transitions
- Debounce updates to max 1/sec per stat
- Log: "WebSocket connected" on success
- Log: "Reconnecting..." on failure
```

---

## PROMPT 2: Layer Toggle Animations
**Position**: At line ~365 (replace `function toggleWeatherLayer`)  
**Action**: Select the 4 toggle functions, press **Ctrl+I**, paste

```
TASK: Replace simple console.log() with animated layer management

FOR EACH LAYER (weather, earthquake, satellite, ship):
1. Add fade-in/fade-out animation when toggling
2. Show toast notification (top-right corner):
   - "Weather radar enabled" (green color, 2sec auto-dismiss)
   - "Earthquakes disabled" (orange color, 2sec auto-dismiss)
3. Add layer count below each toggle showing active markers
4. Keep glassmorphism styling consistent
5. Use CSS transitions for smooth fade (0.3s duration)

TOAST NOTIFICATION STYLE:
- Position: fixed, top-right
- Background: rgba(0, 212, 255, 0.1)
- Border: 1px solid rgba(0, 212, 255, 0.3)
- Border-radius: 8px
- Padding: 1rem
- Max-width: 300px
- Auto-dismiss after 2 seconds
```

---

## PROMPT 3: Stat Cards Pulse Animation
**Position**: In `<style>` section (around line 200)  
**Action**: Position cursor, press **Ctrl+I**, paste

```
TASK: Add CSS animation for pulsing stat cards when data updates

CREATE:
1. @keyframes pulse animation:
   - 0%: box-shadow 0 0 0 0 rgba(0, 212, 255, 0.7)
   - 50%: box-shadow 0 0 0 10px rgba(0, 212, 255, 0)
   - 100%: box-shadow 0 0 0 0 rgba(0, 212, 255, 0)
   - Duration: 1s
   
2. Add .stat-updating class:
   - Apply pulse animation
   - Triggered when stat value changes
   
3. Add smooth number transition:
   - Use CSS counter-increment or JS counter animation
   - Duration: 1s
   - Ease function: cubic-bezier(0.25, 0.46, 0.45, 0.94)

EXAMPLE USAGE:
- Stat card pulses when data updates
- After 1s pulse, returns to normal
- Number animates smoothly from old to new value
```

---

## PROMPT 4: Pan/Zoom Map Controls
**Position**: After map initialization (around line 380+)  
**Action**: Press **Ctrl+I**, paste

```
TASK: Enhance Leaflet map with smooth control buttons

ADD BUTTONS IN CONTROL PANEL:
1. Center on [World, Healthcare, Research, Data Centers, Coastal] buttons
   - Smooth fly animation to center + appropriate zoom
   - Healthcare zoom level 3, others zoom 4
   - Duration: 1.5 seconds
   
2. Add keyboard shortcuts:
   - Number 1-5: Switch between node categories
   - 'z': Zoom to fit all nodes
   - 'h': Home (reset to [20, 0] zoom 3)

SMOOTH ANIMATION PATTERN:
map.flyTo([lat, lng], zoomLevel, {
    duration: 1.5,
    easeLinearity: 0.25
});

STYLING:
- Buttons in new "Quick Nav" section
- Glassmorphism style (consistent with control panel)
- Icons from Font Awesome or inline SVG
```

---

## PROMPT 5: Live Data Layers
**Position**: Before closing `</script>` tag  
**Action**: Press **Ctrl+I**, paste

```
TASK: Add placeholder for real-time data layer sources

IMPLEMENT:
1. Earthquake layer:
   - Fetch from: https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson
   - Show magnitude 4.0+ only
   - Color code by magnitude (green < 5.0, orange 5.0-6.0, red > 6.0)
   - Add popup with magnitude, location, time
   
2. Weather radar layer:
   - Placeholder for RainViewer API integration
   - Will connect to backend Qwen2.5 analysis
   
3. Add layer refresh rates:
   - Earthquakes: every 60 seconds
   - Weather: every 300 seconds (5 min)
   - Ship traffic: every 120 seconds

CODE STRUCTURE:
- Use async/await fetch
- Error handling with try/catch
- Show loading spinner while fetching
- Cache results with timestamp validation
```

---

## TESTING AFTER EACH PROMPT

After pasting each prompt:

1. **Accept** code by pressing Enter
2. **Review** in editor (Ctrl+Z if not happy)
3. **Save** file (Ctrl+S)
4. **Test** in browser (F12 console for errors)

---

## QUICK REFERENCE: Continue Shortcuts

| Key | Action | Use When |
|-----|--------|----------|
| **Ctrl+I** | Code generation | Pasting prompt from this file |
| **Ctrl+L** | Chat with Codestral | Asking questions, debugging |
| **Tab** | Accept autocomplete | Codestral suggests code snippet |
| **Escape** | Reject suggestion | You don't like the code |
| **Ctrl+Z** | Undo | Last change didn't work |
| **Ctrl+Shift+P** | Command palette | Search for Continue commands |

---

## ⏱️ TIME ESTIMATES

| Prompt | Time | Difficulty |
|--------|------|------------|
| #1 WebSocket | 8 min | Medium |
| #2 Animations | 6 min | Easy |
| #3 Pulse effect | 3 min | Easy |
| #4 Map controls | 5 min | Medium |
| #5 Data layers | 4 min | Hard |
| **TOTAL Phase 2** | **30 min** | - |

---

## WHAT TO DO IF STUCK

### Code has syntax errors
**Solution**: 
1. Press Ctrl+L
2. Chat: "Fix the syntax error in the code you just generated"
3. Codestral will provide corrected code

### WebSocket not connecting
**Solution**: 
- FastAPI backend hasn't started yet
- That's ok - Phase 4 creates the backend
- Dashboard will work fine without WebSocket (falls back gracefully)

### Toast notifications don't show
**Solution**:
1. Make sure CSS is in `<style>` section
2. Check browser console (F12) for JavaScript errors
3. Verify element IDs match (#activeNodes, etc)

### Stats not updating
**Solution**:
- Check WebSocket connection status (green/red dot)
- Verify backend is running (`curl http://localhost:8000/health`)
- Check browser console for errors (F12)

---

## SUCCESS INDICATORS

After Phase 2 is complete:

- [ ] Map displays correctly
- [ ] All 25 infrastructure nodes visible
- [ ] Control panel shows stats cards
- [ ] Layer toggles work (checkbox on/off)
- [ ] Keyboard shortcuts work (press '1' → zoom to Healthcare)
- [ ] Pan/zoom animations smooth
- [ ] Toast notifications appear when toggling layers
- [ ] Connection indicator visible (will be red until backend starts)
- [ ] No errors in browser console (F12)
- [ ] Page loads in <2 seconds

---

## NEXT: PHASE 3

Once Phase 2 complete:

1. **Open**: `globe-3d.html`
2. **Read**: `PHASE_3_CONTINUE_PROMPTS.md`
3. **Use**: Same Ctrl+I workflow with Three.js prompts
4. **Time**: 30 minutes

---

## FILES YOU'RE EDITING

```
index.html (3182 lines)
├── HEAD section (line 1-50)
├── STYLE section (line 51-200)  ← Add pulse animation here
├── BODY section (line 201-350)
└── SCRIPT section (line 351+)   ← Add WebSocket + other scripts here
```

**Total additions**: ~500 lines of code/CSS from Phase 2

---

**Status**: 🟢 Ready to paste! Open index.html and press Ctrl+I
