# Phase 2: WMS Testing Guide

**Status:** Ready for Testing  
**Date:** November 10, 2025

---

## Quick Start Testing

### Browser DevTools Setup
1. Open Chrome DevTools (F12)
2. Go to **Network** tab
3. Filter by `wms` or `geoserver`
4. Go to **Console** tab for error monitoring

---

## Test 1: Check Geoserver Accessibility

### Run in Browser Console
```javascript
// Test Geoserver connection
fetch('http://136.243.155.166:8080/geoserver/web/', {mode: 'no-cors'})
    .then(() => console.log('✅ Geoserver accessible'))
    .catch(e => console.error('❌ Geoserver not accessible:', e));
```

**Expected Result:** ✅ Geoserver accessible

---

## Test 2: Verify WMS Capabilities

### Run in Browser Console
```javascript
// Get WMS service capabilities
const url = 'http://136.243.155.166:8080/geoserver/wms?service=wms&version=1.1.0&request=GetCapabilities';
fetch(url, {mode: 'no-cors'})
    .then(r => r.text())
    .then(text => {
        if (text.includes('healthcare_network')) {
            console.log('✅ Healthcare layer found');
        }
        if (text.includes('research_zones')) {
            console.log('✅ Research layer found');
        }
        if (text.includes('infrastructure_network')) {
            console.log('✅ Infrastructure layer found');
        }
        console.log('Full capabilities:', text.substring(0, 500));
    })
    .catch(e => console.error('Error fetching capabilities:', e));
```

**Expected Result:** Layer names found in capabilities XML

---

## Test 3: Test 2D Map WMS Layers

### In Browser Console
```javascript
// Access 2D map instance
const map = window.networkMap;

// Check if WMS layers exist
console.log('WMS Layers available:', Object.keys(map.wmsLayers));

// Verify control panel created
console.log('WMS Controls:', document.querySelector('.wms-control-panel'));

// Toggle layers manually
map.toggleWMSLayer('Healthcare Network', true);
console.log('Healthcare layer toggled ON');
```

### Manual Testing
1. Open the dashboard at production URL
2. **Expected:** WMS control panel appears top-left of 2D map
3. **Check each checkbox:**
   - [ ] Healthcare Network toggles on (map shows healthcare overlay)
   - [ ] Research Zones toggles on (map shows research overlay)
   - [ ] Infrastructure toggles on (map shows infrastructure overlay)
   - [ ] Multiple layers can be enabled simultaneously
   - [ ] Layers toggle off when unchecked

### Browser Zoom & Pan Test
1. Enable at least one WMS layer
2. Zoom in/out - layers should adjust
3. Pan around map - layers should load smoothly
4. No visual glitches or freezing

---

## Test 4: Test 3D Globe WMS Layers

### In Browser Console
```javascript
// Access 3D globe instance
const globe = window.globeApp;

// Check if WMS layers exist
console.log('WMS Layers:', Object.keys(globe.wmsLayers));

// Verify control panel created
console.log('WMS Controls:', document.querySelector('.wms-control-panel'));

// Manually test toggle
globe.toggleWMSLayer({target: {id: 'wms-healthcare', checked: true}});
console.log('Healthcare layer added to 3D globe');
```

### Manual Testing
1. Switch to 3D globe view
2. **Expected:** WMS control panel appears top-left of 3D viewer
3. **Check each checkbox:**
   - [ ] Healthcare WMS renders on 3D globe
   - [ ] Research WMS renders on 3D globe
   - [ ] Infrastructure WMS renders on 3D globe
   - [ ] Layers are semi-transparent (globe visible beneath)
   - [ ] Multiple layers can be visible

### 3D Navigation Test
1. Enable WMS layers
2. Rotate 3D globe - WMS layers should rotate with it
3. Zoom in/out - WMS should adjust
4. Tilt view - layers should tilt naturally

---

## Test 5: Network Performance

### Monitor Network Requests
1. Open DevTools Network tab
2. Clear cache (hard refresh: Ctrl+Shift+R)
3. Toggle a WMS layer ON
4. Watch Network tab

**Expected:**
- Initial WMS request: 200-500ms
- Multiple tile requests appear
- Tiles load progressively
- Requests should show PNG images

### Performance Metrics
```javascript
// Check performance
const perfData = performance.getEntriesByType('resource')
    .filter(r => r.name.includes('geoserver') || r.name.includes('wms'));
    
console.log('WMS Requests:', perfData.length);
console.log('Total WMS load time:', perfData.reduce((sum, p) => sum + p.duration, 0) + 'ms');
```

**Expected:** 
- < 10 WMS requests on first load
- < 2000ms total time
- Cached tiles load in <50ms

---

## Test 6: Error Handling

### Simulate Geoserver Down
1. In browser console, change Geoserver URL to invalid:
```javascript
// Force error condition
const map = window.networkMap;
map.geoserverUrl = 'http://invalid-url:9999/wms';

// Try to toggle layer
map.toggleWMSLayer('Healthcare Network', true);
```

**Expected:**
- ✅ Console error logged (graceful)
- ✅ Map still works (no crash)
- ✅ Other layers still functional

### Check Console
```javascript
// See all console messages
console.log('%cChecking console errors...', 'color: blue; font-size: 14px');

// Filter errors
console.group('WMS Errors');
console.error('If WMS service unavailable, error should appear here');
console.groupEnd();
```

---

## Test 7: Persistence Testing

### LocalStorage Verification
1. Enable some WMS layers on 2D map
2. Reload page (F5)
3. **Expected:** Same WMS layers still enabled
4. Check console:
```javascript
console.log('Stored preferences:', localStorage.getItem('wmsLayerPreferences'));
```

---

## Test 8: Cross-Browser Testing

### Test in Each Browser

#### Chrome
- [ ] WMS layers load and display correctly
- [ ] Control panels responsive
- [ ] No console errors

#### Firefox
- [ ] WMS layers load and display correctly
- [ ] Control panels responsive
- [ ] No console errors

#### Safari
- [ ] WMS layers load and display correctly
- [ ] Control panels responsive
- [ ] No console errors

#### Edge
- [ ] WMS layers load and display correctly
- [ ] Control panels responsive
- [ ] No console errors

---

## Test 9: Responsive Design

### Mobile Testing
1. Open DevTools (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M)
3. Test various screen sizes:
   - [ ] iPhone SE (375px)
   - [ ] iPhone 12 Pro (390px)
   - [ ] iPad (768px)
   - [ ] iPad Pro (1024px)

**Expected:**
- WMS controls adjust to screen size
- Checkboxes still clickable
- No horizontal scrolling
- Map/globe still functional

---

## Test 10: Accessibility Testing

### Keyboard Navigation
```javascript
// In browser console, test keyboard accessibility
console.log('Focus first checkbox:', document.querySelector('.wms-checkbox input').focus());

// Try Tab key to navigate checkboxes
// Try Space/Enter to toggle
```

**Expected:**
- Tab key focuses checkboxes
- Space/Enter toggles checkbox
- No keyboard traps

### Screen Reader Testing (if available)
- Enable screen reader
- Navigate to WMS control panel
- Verify labels are announced

---

## Debugging Checklist

### If WMS Layers Not Appearing

**Step 1: Check Network**
```javascript
fetch('http://136.243.155.166:8080/geoserver/wms?service=wms&version=1.1.0&request=GetCapabilities')
    .then(r => r.text())
    .then(console.log)
    .catch(e => console.error('Network error:', e));
```

**Step 2: Check Layer Names**
```javascript
// Print expected layer names
console.log('Expected layers:', [
    'geoserver:healthcare_network',
    'geoserver:research_zones',
    'geoserver:infrastructure_network'
]);

// Query actual available layers
// (Requires parsing GetCapabilities response)
```

**Step 3: Check Map Instance**
```javascript
const map = window.networkMap;
console.log('Map exists:', !!map);
console.log('WMS Layers object:', map.wmsLayers);
console.log('Healthcare layer:', map.wmsLayers['Healthcare Network']);
```

**Step 4: Check 3D Globe Instance**
```javascript
const globe = window.globeApp;
console.log('Globe exists:', !!globe);
console.log('Globe viewer:', !!globe.viewer);
console.log('WMS layers:', globe.wmsLayers);
```

### If Layers Load Slowly

**Check:**
- Geoserver performance: `http://136.243.155.166:8080/geoserver/web/`
- Network speed in DevTools
- Browser cache (hard refresh: Ctrl+Shift+R)

**Optimize:**
- Reduce WMS layer opacity (less data to render)
- Limit zoom levels
- Request simpler layer styles from Geoserver

### If CORS Errors

**Check DevTools Console:** Look for "Access to XMLHttpRequest blocked by CORS policy"

**Solution:**
- Verify Geoserver CORS is enabled
- Check CORS headers: `Access-Control-Allow-Origin: *`
- May need proxy if Geoserver CORS misconfigured

---

## Test Completion Checklist

- [ ] Test 1: Geoserver accessible ✅
- [ ] Test 2: WMS capabilities verified ✅
- [ ] Test 3: 2D map layers functional ✅
- [ ] Test 4: 3D globe layers functional ✅
- [ ] Test 5: Network performance acceptable ✅
- [ ] Test 6: Error handling graceful ✅
- [ ] Test 7: Preferences persist ✅
- [ ] Test 8: Cross-browser compatible ✅
- [ ] Test 9: Responsive on mobile ✅
- [ ] Test 10: Accessible via keyboard ✅

---

## Deployment Readiness

### When All Tests Pass:
1. [ ] Code review complete
2. [ ] No console errors in any browser
3. [ ] Performance metrics acceptable
4. [ ] Documentation complete
5. [ ] Ready for production deployment

### Deployment Command
```bash
git push origin main
# Automatic GitHub Actions deployment triggers
# Monitor at: https://github.com/[repo]/actions
```

---

## Post-Deployment Monitoring

### First 24 Hours
- [ ] Monitor error logs
- [ ] Check performance metrics
- [ ] Verify user feedback
- [ ] Monitor Geoserver load

### Metrics to Watch
- WMS request success rate (target: >99%)
- Average tile load time (target: <500ms)
- User engagement with WMS controls
- Any console errors reported

---

**Status:** Ready to Test  
**Next Step:** Execute tests in staging environment  
**Timeline:** 2-4 hours for complete testing
