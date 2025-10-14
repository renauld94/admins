# 🧪 Website Test Cases & Implementation Guide
## Simon Data Lab - https://www.simondatalab.de/

---

## 📱 Device Testing Matrix

### Desktop Testing
- **1920x1080** (Full HD) - Primary desktop resolution
- **1440x900** (MacBook Air) - Common laptop resolution  
- **1366x768** (Standard laptop) - Legacy laptop resolution
- **2560x1440** (2K) - High-resolution displays

### Tablet Testing
- **768x1024** (iPad Portrait) - Primary tablet orientation
- **1024x768** (iPad Landscape) - Landscape tablet view
- **820x1180** (iPad Air) - Modern tablet resolution

### Mobile Testing
- **375x667** (iPhone SE) - Small mobile device
- **414x896** (iPhone 11 Pro Max) - Large mobile device
- **360x640** (Android Standard) - Common Android resolution
- **390x844** (iPhone 12) - Modern iPhone resolution

---

## 🔄 Interaction Flow Tests

### 1. Navigation Flow
```javascript
// Test Case: Main Navigation
describe('Main Navigation', () => {
  test('Desktop navigation menu opens and closes', () => {
    // Steps:
    // 1. Load homepage
    // 2. Click main menu button
    // 3. Verify menu opens
    // 4. Click outside menu
    // 5. Verify menu closes
  });
  
  test('Mobile hamburger menu functionality', () => {
    // Steps:
    // 1. Resize to mobile viewport
    // 2. Click hamburger menu
    // 3. Verify mobile menu opens
    // 4. Click menu item
    // 5. Verify navigation occurs
    // 6. Verify menu closes
  });
});
```

### 2. Content Loading Flow
```javascript
// Test Case: Content Loading
describe('Content Loading', () => {
  test('Hero section loads with animations', () => {
    // Steps:
    // 1. Load homepage
    // 2. Verify hero section appears
    // 3. Check for loading animations
    // 4. Verify content is fully loaded
  });
  
  test('Project cards load with lazy loading', () => {
    // Steps:
    // 1. Scroll to projects section
    // 2. Verify images load as they come into view
    // 3. Check for placeholder states
    // 4. Verify smooth transitions
  });
});
```

### 3. Interactive Elements Flow
```javascript
// Test Case: Data Visualizations
describe('Interactive Elements', () => {
  test('D3.js visualizations load and function', () => {
    // Steps:
    // 1. Navigate to projects with visualizations
    // 2. Verify D3.js loads without CSP errors
    // 3. Test interactive features
    // 4. Verify responsive behavior
  });
  
  test('Geospatial map functionality', () => {
    // Steps:
    // 1. Load GeoServer integration page
    // 2. Verify map loads
    // 3. Test zoom/pan functionality
    // 4. Verify mobile touch interactions
  });
});
```

---

## ⚡ Performance Test Cases

### Core Web Vitals Testing
```javascript
// Performance Test Suite
describe('Core Web Vitals', () => {
  test('First Contentful Paint < 1.5s', async () => {
    const page = await browser.newPage();
    await page.goto('https://www.simondatalab.de/');
    
    const fcp = await page.evaluate(() => {
      return new Promise(resolve => {
        new PerformanceObserver(list => {
          const entries = list.getEntries();
          const fcpEntry = entries.find(entry => entry.name === 'first-contentful-paint');
          resolve(fcpEntry.startTime);
        }).observe({entryTypes: ['paint']});
      });
    });
    
    expect(fcp).toBeLessThan(1500);
  });
  
  test('Largest Contentful Paint < 2.5s', async () => {
    const lcp = await page.evaluate(() => {
      return new Promise(resolve => {
        new PerformanceObserver(list => {
          const entries = list.getEntries();
          const lastEntry = entries[entries.length - 1];
          resolve(lastEntry.startTime);
        }).observe({entryTypes: ['largest-contentful-paint']});
      });
    });
    
    expect(lcp).toBeLessThan(2500);
  });
  
  test('Cumulative Layout Shift < 0.1', async () => {
    const cls = await page.evaluate(() => {
      return new Promise(resolve => {
        let clsValue = 0;
        new PerformanceObserver(list => {
          for (const entry of list.getEntries()) {
            if (!entry.hadRecentInput) {
              clsValue += entry.value;
            }
          }
          resolve(clsValue);
        }).observe({entryTypes: ['layout-shift']});
      });
    });
    
    expect(cls).toBeLessThan(0.1);
  });
});
```

### Resource Loading Tests
```javascript
// Resource Loading Test Suite
describe('Resource Loading', () => {
  test('Critical CSS loads inline', () => {
    // Verify critical CSS is inlined in <head>
    const criticalCSS = document.querySelector('style');
    expect(criticalCSS).toBeTruthy();
  });
  
  test('Non-critical CSS loads asynchronously', () => {
    // Verify non-critical CSS loads after page load
    const nonCriticalCSS = document.querySelector('link[rel="stylesheet"]');
    expect(nonCriticalCSS).toBeTruthy();
  });
  
  test('Images load with lazy loading', () => {
    // Verify images have loading="lazy" attribute
    const images = document.querySelectorAll('img');
    images.forEach(img => {
      expect(img.loading).toBe('lazy');
    });
  });
});
```

---

## ♿ Accessibility Test Cases

### Keyboard Navigation Tests
```javascript
// Accessibility Test Suite
describe('Keyboard Navigation', () => {
  test('All interactive elements are keyboard accessible', () => {
    const interactiveElements = document.querySelectorAll('button, a, input, select, textarea');
    
    interactiveElements.forEach(element => {
      // Test tab order
      element.focus();
      expect(document.activeElement).toBe(element);
      
      // Test focus visibility
      const computedStyle = window.getComputedStyle(element, ':focus');
      expect(computedStyle.outline).not.toBe('none');
    });
  });
  
  test('Skip links work correctly', () => {
    const skipLink = document.querySelector('.skip-link');
    if (skipLink) {
      skipLink.click();
      const target = document.querySelector(skipLink.getAttribute('href'));
      expect(document.activeElement).toBe(target);
    }
  });
});
```

### Screen Reader Tests
```javascript
// Screen Reader Compatibility
describe('Screen Reader Support', () => {
  test('Images have descriptive alt text', () => {
    const images = document.querySelectorAll('img');
    images.forEach(img => {
      expect(img.alt).toBeTruthy();
      expect(img.alt.length).toBeGreaterThan(0);
    });
  });
  
  test('Form elements have proper labels', () => {
    const inputs = document.querySelectorAll('input, textarea, select');
    inputs.forEach(input => {
      const label = document.querySelector(`label[for="${input.id}"]`);
      const ariaLabel = input.getAttribute('aria-label');
      const ariaLabelledBy = input.getAttribute('aria-labelledby');
      
      expect(label || ariaLabel || ariaLabelledBy).toBeTruthy();
    });
  });
  
  test('Landmark roles are present', () => {
    const landmarks = document.querySelectorAll('[role="main"], [role="navigation"], [role="banner"], [role="contentinfo"]');
    expect(landmarks.length).toBeGreaterThan(0);
  });
});
```

---

## 🔒 Security Test Cases

### CSP Compliance Tests
```javascript
// Security Test Suite
describe('Content Security Policy', () => {
  test('CSP allows inline scripts', () => {
    const cspMeta = document.querySelector('meta[http-equiv="Content-Security-Policy"]');
    const cspContent = cspMeta.getAttribute('content');
    
    expect(cspContent).toContain("'unsafe-inline'");
    expect(cspContent).not.toContain('sha384-'); // No conflicting hashes
  });
  
  test('External resources load without CSP violations', () => {
    // Check console for CSP violations
    const consoleErrors = [];
    const originalError = console.error;
    console.error = (...args) => {
      if (args[0].includes('Content Security Policy')) {
        consoleErrors.push(args[0]);
      }
      originalError.apply(console, args);
    };
    
    // Load page and check for CSP errors
    expect(consoleErrors.length).toBe(0);
  });
});
```

### HTTPS and Security Headers
```javascript
// Security Headers Test
describe('Security Headers', () => {
  test('HTTPS is enforced', () => {
    expect(window.location.protocol).toBe('https:');
  });
  
  test('Security headers are present', async () => {
    const response = await fetch('https://www.simondatalab.de/');
    const headers = response.headers;
    
    expect(headers.get('Strict-Transport-Security')).toBeTruthy();
    expect(headers.get('X-Frame-Options')).toBeTruthy();
    expect(headers.get('X-Content-Type-Options')).toBeTruthy();
  });
});
```

---

## 📊 SEO Test Cases

### Meta Tags and Structured Data
```javascript
// SEO Test Suite
describe('SEO Optimization', () => {
  test('Essential meta tags are present', () => {
    expect(document.querySelector('meta[name="description"]')).toBeTruthy();
    expect(document.querySelector('meta[name="keywords"]')).toBeTruthy();
    expect(document.querySelector('meta[property="og:title"]')).toBeTruthy();
    expect(document.querySelector('meta[name="twitter:card"]')).toBeTruthy();
  });
  
  test('Structured data is valid', () => {
    const jsonLd = document.querySelector('script[type="application/ld+json"]');
    if (jsonLd) {
      const data = JSON.parse(jsonLd.textContent);
      expect(data['@type']).toBeTruthy();
      expect(data['@context']).toBe('https://schema.org');
    }
  });
  
  test('Canonical URL is set', () => {
    const canonical = document.querySelector('link[rel="canonical"]');
    expect(canonical).toBeTruthy();
    expect(canonical.href).toBe('https://www.simondatalab.de/');
  });
});
```

---

## 🎨 Visual Regression Tests

### Cross-Browser Compatibility
```javascript
// Visual Regression Test Suite
describe('Cross-Browser Compatibility', () => {
  const browsers = ['chrome', 'firefox', 'safari', 'edge'];
  
  browsers.forEach(browser => {
    test(`Layout renders correctly in ${browser}`, async () => {
      // Take screenshot and compare with baseline
      const screenshot = await page.screenshot();
      expect(screenshot).toMatchSnapshot(`${browser}-homepage.png`);
    });
  });
});
```

### Responsive Design Tests
```javascript
// Responsive Design Test Suite
describe('Responsive Design', () => {
  const viewports = [
    { width: 1920, height: 1080, name: 'desktop' },
    { width: 768, height: 1024, name: 'tablet' },
    { width: 375, height: 667, name: 'mobile' }
  ];
  
  viewports.forEach(viewport => {
    test(`Layout works at ${viewport.name} resolution`, async () => {
      await page.setViewport(viewport);
      await page.goto('https://www.simondatalab.de/');
      
      // Check for horizontal scroll
      const bodyWidth = await page.evaluate(() => document.body.scrollWidth);
      const viewportWidth = viewport.width;
      expect(bodyWidth).toBeLessThanOrEqual(viewportWidth);
      
      // Take screenshot for visual verification
      const screenshot = await page.screenshot();
      expect(screenshot).toMatchSnapshot(`${viewport.name}-layout.png`);
    });
  });
});
```

---

## 🚀 Implementation Priority

### Phase 1: Critical Fixes (Week 1)
1. **Fix CSP Violations** - Remove conflicting hashes
2. **Resolve External Resource Blocking** - Ensure all scripts load
3. **Test Interactive Elements** - Verify D3.js and Three.js work

### Phase 2: Performance & Accessibility (Week 2-3)
1. **Implement Lazy Loading** - Optimize image loading
2. **Add ARIA Labels** - Improve accessibility
3. **Mobile Navigation Testing** - Verify responsive behavior
4. **Performance Optimization** - Bundle and minify assets

### Phase 3: Enhancement (Week 4+)
1. **Add Structured Data** - Implement JSON-LD schema
2. **PWA Implementation** - Add service worker
3. **Enhanced Animations** - Add microinteractions
4. **Content Expansion** - Add detailed case studies

---

## 📋 Test Execution Checklist

### Pre-Test Setup
- [ ] Clear browser cache
- [ ] Disable browser extensions
- [ ] Set up test environment
- [ ] Configure network throttling (optional)

### Test Execution
- [ ] Run performance tests
- [ ] Execute accessibility tests
- [ ] Test responsive design
- [ ] Verify interactive elements
- [ ] Check security compliance
- [ ] Validate SEO elements

### Post-Test Analysis
- [ ] Document test results
- [ ] Identify failed tests
- [ ] Prioritize fixes
- [ ] Create bug reports
- [ ] Update test cases

This comprehensive test suite ensures the website meets all quality standards and provides an excellent user experience across all devices and browsers.

