#!/usr/bin/env node
/**
 * QA Screenshot Tool - Desktop & Mobile
 * Generates deterministic screenshots at multiple viewports
 * and reports DOM presence of key elements
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const TARGET_URL = process.env.TARGET_URL || 'https://www.simondatalab.de';
const OUTPUT_DIR = path.join(__dirname, '../reports');

const VIEWPORTS = {
  mobile: { width: 393, height: 851, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
  tablet: { width: 768, height: 1024, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
  desktop: { width: 1920, height: 1080, deviceScaleFactor: 1, isMobile: false, hasTouch: false }
};

const DOM_CHECKS = [
  { selector: '#hero-visualization', description: 'Hero visualization container' },
  { selector: '.globe-fab', description: 'Globe FAB (should be removed)' },
  { selector: '#load-advanced-viz-cta', description: 'Load viz CTA (should be hidden)' },
  { selector: 'canvas', description: 'Canvas elements (check count and position)' },
  { selector: '.mobile-nav', description: 'Mobile navigation' },
  { selector: '.admin-menu', description: 'Admin menu' }
];

async function runQA() {
  console.log('🚀 Starting QA Screenshot & DOM Check...\n');
  
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const results = {
    url: TARGET_URL,
    timestamp: new Date().toISOString(),
    viewports: {},
    summary: { passed: 0, warnings: 0, failed: 0 }
  };

  for (const [name, viewport] of Object.entries(VIEWPORTS)) {
    console.log(`📱 Testing ${name} viewport (${viewport.width}x${viewport.height})...`);
    
    const page = await browser.newPage();
    await page.setViewport(viewport);
    
    try {
      // Navigate and wait for network idle
      await page.goto(TARGET_URL, { 
        waitUntil: 'networkidle2',
        timeout: 30000 
      });

      // Wait a bit for any animations/lazy loads
      await page.waitForTimeout(2000);

      // Take screenshot
      const screenshotPath = path.join(OUTPUT_DIR, `qa_${name}.png`);
      await page.screenshot({ 
        path: screenshotPath, 
        fullPage: false // Above-the-fold only
      });
      console.log(`  ✅ Screenshot saved: ${screenshotPath}`);

      // Run DOM checks
      const domResults = await page.evaluate((checks) => {
        return checks.map(check => {
          const elements = document.querySelectorAll(check.selector);
          const element = elements[0];
          
          let result = {
            selector: check.selector,
            description: check.description,
            found: elements.length > 0,
            count: elements.length,
            visible: false,
            position: null,
            computedStyle: null
          };

          if (element) {
            const rect = element.getBoundingClientRect();
            const styles = window.getComputedStyle(element);
            
            result.visible = rect.width > 0 && rect.height > 0 && styles.display !== 'none' && styles.visibility !== 'hidden';
            result.position = {
              top: Math.round(rect.top),
              left: Math.round(rect.left),
              width: Math.round(rect.width),
              height: Math.round(rect.height)
            };
            result.computedStyle = {
              display: styles.display,
              visibility: styles.visibility,
              opacity: styles.opacity
            };
          }

          return result;
        });
      }, DOM_CHECKS);

      // Get console logs
      const consoleLogs = [];
      page.on('console', msg => {
        const type = msg.type();
        if (['error', 'warning'].includes(type)) {
          consoleLogs.push({ type, text: msg.text() });
        }
      });

      // Check for specific issues
      const issues = [];
      const heroViz = domResults.find(r => r.selector === '#hero-visualization');
      const globeFab = domResults.find(r => r.selector === '.globe-fab');
      const ctaButton = domResults.find(r => r.selector === '#load-advanced-viz-cta');
      const canvases = domResults.find(r => r.selector === 'canvas');

      if (!heroViz || !heroViz.found) {
        issues.push({ severity: 'error', message: 'Hero visualization container not found' });
        results.summary.failed++;
      } else if (!heroViz.visible) {
        issues.push({ severity: 'warning', message: 'Hero visualization container exists but not visible' });
        results.summary.warnings++;
      } else {
        results.summary.passed++;
      }

      if (globeFab && globeFab.visible) {
        issues.push({ severity: 'warning', message: 'Globe FAB is visible (should be removed)' });
        results.summary.warnings++;
      } else {
        results.summary.passed++;
      }

      if (ctaButton && ctaButton.visible) {
        issues.push({ severity: 'warning', message: 'Load viz CTA is visible (should be hidden)' });
        results.summary.warnings++;
      } else {
        results.summary.passed++;
      }

      if (canvases && canvases.count > 1) {
        issues.push({ 
          severity: 'warning', 
          message: `Multiple canvas elements found (${canvases.count}). Check for duplicate visualizations.` 
        });
        results.summary.warnings++;
      }

      results.viewports[name] = {
        viewport,
        screenshot: screenshotPath,
        domChecks: domResults,
        issues,
        consoleLogs
      };

      console.log(`  ℹ️  Found ${domResults.filter(r => r.found).length}/${domResults.length} elements`);
      console.log(`  ⚠️  Issues: ${issues.length}`);
      if (issues.length > 0) {
        issues.forEach(issue => {
          console.log(`     ${issue.severity === 'error' ? '❌' : '⚠️ '} ${issue.message}`);
        });
      }

      await page.close();
      
    } catch (error) {
      console.error(`  ❌ Error testing ${name}:`, error.message);
      results.viewports[name] = {
        viewport,
        error: error.message
      };
      results.summary.failed++;
    }
    
    console.log('');
  }

  await browser.close();

  // Save JSON report
  const reportPath = path.join(OUTPUT_DIR, 'qa_report.json');
  fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
  console.log(`📄 QA Report saved: ${reportPath}\n`);

  // Print summary
  console.log('📊 QA Summary:');
  console.log(`   ✅ Passed: ${results.summary.passed}`);
  console.log(`   ⚠️  Warnings: ${results.summary.warnings}`);
  console.log(`   ❌ Failed: ${results.summary.failed}`);
  console.log('');

  // Generate markdown report
  generateMarkdownReport(results);

  return results;
}

function generateMarkdownReport(results) {
  const lines = [];
  
  lines.push('# QA Test Report');
  lines.push('');
  lines.push(`**URL:** ${results.url}`);
  lines.push(`**Date:** ${new Date(results.timestamp).toLocaleString()}`);
  lines.push('');
  
  lines.push('## Summary');
  lines.push('');
  lines.push(`- ✅ Passed: ${results.summary.passed}`);
  lines.push(`- ⚠️ Warnings: ${results.summary.warnings}`);
  lines.push(`- ❌ Failed: ${results.summary.failed}`);
  lines.push('');

  for (const [name, viewport] of Object.entries(results.viewports)) {
    lines.push(`## ${name.charAt(0).toUpperCase() + name.slice(1)} Viewport`);
    lines.push('');
    
    if (viewport.error) {
      lines.push(`❌ **Error:** ${viewport.error}`);
      lines.push('');
      continue;
    }

    lines.push(`**Resolution:** ${viewport.viewport.width}x${viewport.viewport.height}`);
    lines.push(`**Screenshot:** \`${path.basename(viewport.screenshot)}\``);
    lines.push('');

    if (viewport.issues && viewport.issues.length > 0) {
      lines.push('### Issues');
      lines.push('');
      viewport.issues.forEach(issue => {
        const icon = issue.severity === 'error' ? '❌' : '⚠️';
        lines.push(`${icon} **${issue.severity.toUpperCase()}:** ${issue.message}`);
      });
      lines.push('');
    }

    lines.push('### DOM Checks');
    lines.push('');
    lines.push('| Element | Found | Visible | Count | Position |');
    lines.push('|---------|-------|---------|-------|----------|');
    
    viewport.domChecks.forEach(check => {
      const found = check.found ? '✅' : '❌';
      const visible = check.visible ? '✅' : '⬜';
      const pos = check.position ? `${check.position.width}x${check.position.height} @ (${check.position.left}, ${check.position.top})` : 'N/A';
      lines.push(`| ${check.description} | ${found} | ${visible} | ${check.count} | ${pos} |`);
    });
    lines.push('');
  }

  const reportPath = path.join(OUTPUT_DIR, 'QA_REPORT.md');
  fs.writeFileSync(reportPath, lines.join('\n'));
  console.log(`📝 Markdown report saved: ${reportPath}`);
}

// Run if executed directly
if (require.main === module) {
  runQA().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
  });
}

module.exports = { runQA };
