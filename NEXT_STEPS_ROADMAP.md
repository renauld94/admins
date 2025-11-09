# Portfolio Development Roadmap
**Status:** Post-CSS Deployment (Nov 9, 2025)

---

## 🚀 Priority Queue

### **PHASE 1: IMMEDIATE (This Week)**

#### 1.1 **Mobile Device Testing** ⏱️ 30 mins
**Objective:** Verify CSS fixes work on real devices  
**Tasks:**
- [ ] Test on iPhone SE (375px) - iOS Safari
- [ ] Test on Samsung Galaxy A12 (412px) - Android Chrome
- [ ] Test on iPad (768px) - Landscape mode
- [ ] Verify: No horizontal scrolling
- [ ] Verify: Dropdowns work on touch
- [ ] Verify: Forms don't zoom on iOS
- [ ] Verify: Buttons hit 44x44px targets

**Success Criteria:** All devices render correctly, no layout issues

---

#### 1.2 **Add Certificates/Credentials Section** ⏱️ 2-3 hours
**Objective:** Display professional certifications & achievements  
**Current Status:** Missing from portfolio  

**What We Need:**
1. Your certificate data (titles, issuers, dates, URLs)
2. Certificate logos/badges
3. HTML structure with grid layout
4. CSS styling (cards, icons, hover effects)

**Deliverables:**
- New `#certificates` section on index.html
- Responsive grid layout (auto-fit, minmax)
- Card design matching existing expertise cards
- Integration into main navigation

**CSS Template Ready:** ✅ Available in CSS_BOOTSTRAP_THEME_REVIEW.md

---

#### 1.3 **Fix Location Focus Dropdown (Geospatial)** ⏱️ 1 hour
**Objective:** Fix display issue on globe-3d.html:458  
**Problem:** Dropdown not rendering correctly  
**Current Status:** Reported by user

**Investigation Steps:**
1. Inspect `.location-focus-dropdown` CSS
2. Check z-index conflicts
3. Verify positioning (absolute vs fixed)
4. Test on mobile/desktop

**Files Involved:**
- `geospatial-viz/globe-3d.html`
- May need CSS updates to the inline styles

---

### **PHASE 2: HIGH PRIORITY (Next 2 Weeks)**

#### 2.1 **Implement 3D Weather Radar** ⏱️ 4-6 hours
**Objective:** Add weather layer to 3D globe  
**Current Status:** Checkbox exists (line 484) but no JS implementation  

**Implementation Plan:**
1. Add toggleWeatherRadar() function to GlobeApp class
2. Integrate RainViewer API (weather tiles)
3. Add Cesium ImageryLayer for weather overlay
4. Create opacity/visibility controls
5. Test on globe-3d.html

**Files Involved:**
- `geospatial-viz/globe-3d.html` (JavaScript section)
- May add: `geospatial-viz/js/weather-radar.js`

**Example Integration:**
```javascript
function toggleWeatherRadar() {
  if (weatherRadarEnabled) {
    viewer.imageryLayers.add(
      Cesium.ImageryLayer.fromProviderAsync(
        Cesium.TileMapServiceImageryProvider.fromUrl(
          Cesium.IonResource.fromAssetId(rainViewerAssetId)
        )
      )
    );
  } else {
    viewer.imageryLayers.remove(weatherLayer);
  }
}
```

---

#### 2.2 **WCAG Full Compliance Audit** ⏱️ 2-3 hours
**Objective:** Run comprehensive accessibility audit  
**Tools:** axe DevTools, Lighthouse, WAVE

**Check:**
- [ ] Color contrast (all text/backgrounds)
- [ ] Keyboard navigation (all interactive elements)
- [ ] Focus indicators (visible on all focusable elements)
- [ ] Form labels (properly associated with inputs)
- [ ] ARIA labels (where needed)
- [ ] Image alt text (all images)
- [ ] Semantic HTML (proper heading hierarchy)

**Success:** WCAG AA compliance score ≥95%

---

#### 2.3 **Integrate Neural-Hero into Main Portfolio** ⏱️ 2-3 hours
**Objective:** Replace current hero visualization with neural-hero  
**Current Status:** Neural-hero deployed separately at /neural-hero/

**Plan:**
1. Review current hero section in index.html
2. Load `/neural-hero/main.js` instead of epic-neural-cosmos-viz
3. Update hero container styling for seamless integration
4. Test animations & performance
5. Verify fallback still works

**Files Involved:**
- `index.html` (hero section)
- `hero-viz-initialization.js` (loader)
- `styles.css` (hero container)

---

### **PHASE 3: MEDIUM PRIORITY (Nice to Have)**

#### 3.1 **CSS Modularization** ⏱️ 4-6 hours
**Objective:** Split monolithic styles.css into modules  

**Plan:**
```
styles/
├── core/
│   ├── variables.css (color tokens, breakpoints)
│   ├── base.css (resets, typography)
│   └── utilities.css (utility classes)
├── layout/
│   ├── navigation.css (header, nav)
│   ├── footer.css
│   └── grid.css
├── components/
│   ├── buttons.css
│   ├── forms.css
│   ├── cards.css
│   └── modals.css
└── responsive/
    ├── tablet.css (768px+)
    ├── mobile.css (<480px)
    └── ultra-mobile.css (<380px)
```

**Benefits:**
- Easier maintenance
- Better code organization
- Faster debugging
- Reusable components

---

#### 3.2 **Dark Mode Toggle** ⏱️ 2-3 hours
**Objective:** Add light/dark theme switcher  

**Implementation:**
1. Create CSS custom property sets for each theme
2. Add toggle button in header/footer
3. Persist preference in localStorage
4. Detect system preference (prefers-color-scheme)

**Example:**
```css
/* Light theme */
body {
  --bg-primary: #f8fafc;
  --text-primary: #0f172a;
}

/* Dark theme */
body.dark-mode {
  --bg-primary: #0a0f1e;
  --text-primary: #e8eef8;
}
```

---

#### 3.3 **Utility Class System** ⏱️ 3-4 hours
**Objective:** Create Tailwind-like utility classes for rapid prototyping  

**Classes:**
- Spacing: `.p-{sm/md/lg}`, `.m-{sm/md/lg}`, `.gap-{sm/md/lg}`
- Sizing: `.w-{full/half/auto}`, `.h-{full/auto}`
- Colors: `.text-{primary/dark/muted}`, `.bg-{light/dark}`
- Border: `.border-{sm/md/lg}`, `.rounded-{sm/md/lg}`
- Display: `.flex`, `.grid`, `.hidden`, `.block`
- Responsive: `.mobile-only`, `.desktop-only`

**Benefit:** Speed up component development & updates

---

### **PHASE 4: LOW PRIORITY (Polish)**

#### 4.1 **Performance Optimization** ⏱️ 2-3 hours
- CSS minification & compression
- Unused CSS removal (PurgeCSS)
- Critical CSS extraction
- CSS-in-JS elimination (already done)

#### 4.2 **Advanced Animations** ⏱️ 4-6 hours
- Smooth scroll behavior
- Intersection Observer for fade-ins
- Staggered animations
- Parallax effects

#### 4.3 **SEO Enhancements** ⏱️ 2-3 hours
- Schema.org markup (already present)
- Open Graph images
- Structured data validation
- Sitemap updates

---

## 📋 Quick Selection Menu

### **Choose Your Next Task:**

**Option A:** 🧪 **Test on Mobile** (30 mins) — Verify CSS fixes work  
→ Command: Test portfolio on iPhone/Android/iPad

**Option B:** 🎖️ **Add Certificates** (2-3 hours) — Display your credentials  
→ Command: Create certificates section with your data

**Option C:** 🐛 **Fix Dropdown** (1 hour) — Resolve geospatial issue  
→ Command: Debug & fix location focus dropdown

**Option D:** 🌦️ **Weather Radar** (4-6 hours) — Add weather layer to globe  
→ Command: Implement toggleWeatherRadar() function

**Option E:** ♿ **WCAG Audit** (2-3 hours) — Full accessibility check  
→ Command: Run comprehensive compliance audit

**Option F:** 🎨 **Integrate Neural-Hero** (2-3 hours) — Replace hero animation  
→ Command: Integrate neural-hero into main portfolio

**Option G:** 🏗️ **Modularize CSS** (4-6 hours) — Refactor styles  
→ Command: Split styles.css into modules

---

## 💾 Current Status Summary

✅ **Completed:**
- CSS Bootstrap Theme Review (comprehensive analysis)
- Critical CSS Fixes (5 major improvements)
- Production Deployment (HTTP 200 verified)
- Mobile Optimization (480px & 380px breakpoints)

⏳ **In Progress:**
- Mobile device testing (user testing)

❌ **Pending:**
- Certificates section
- Location dropdown fix
- Weather radar
- Neural-hero integration
- WCAG full audit

---

## 🚀 What Do You Want to Do Next?

Type one of:
- **A** — Test on mobile devices
- **B** — Add certificates section (need your data)
- **C** — Fix location dropdown
- **D** — Implement weather radar
- **E** — Run WCAG compliance audit
- **F** — Integrate neural-hero into main portfolio
- **G** — Modularize CSS files
- **Custom** — Something else?

---

**Estimated Total Time for All Tasks:** ~25-30 hours  
**Recommended Approach:** Complete PHASE 1 tasks this week, then tackle PHASE 2
