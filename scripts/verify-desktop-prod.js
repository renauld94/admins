const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const outDir = 'deploy/screenshots';
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 1366, height: 768 } });
  const page = await context.newPage();

  page.on('console', msg => console.log('PAGE_LOG>', msg.text()));
  page.on('pageerror', err => console.error('PAGE_ERROR>', err));

  try {
    console.log('Navigating to https://www.simondatalab.de/ ...');
    await page.goto('https://www.simondatalab.de/', { waitUntil: 'networkidle', timeout: 30000 });
    console.log('Taking hero screenshot...');
    await page.screenshot({ path: `${outDir}/desktop-hero.png`, fullPage: false });

    const navButton = await page.$('.mobile-menu-btn');
    if (navButton) {
      const visible = await navButton.isVisible();
      if (visible) {
        console.log('Found visible .mobile-menu-btn, toggling...');
        await navButton.click();
        await page.waitForTimeout(500);
        await page.screenshot({ path: `${outDir}/desktop-nav-open.png` });
        await navButton.click();
        await page.waitForTimeout(200);
        await page.screenshot({ path: `${outDir}/desktop-nav-closed.png` });
      } else {
        console.log('.mobile-menu-btn present in DOM but not visible (expected on desktop)');
        await page.screenshot({ path: `${outDir}/desktop-no-mobile-btn-visible.png` });
      }
    } else {
      console.log('No .mobile-menu-btn in DOM');
    }

    // capture a couple more important pages
    const pagesToCapture = [
      '/projects',
      '/contact'
    ];
    for (const p of pagesToCapture) {
      try {
        const url = new URL(p, 'https://www.simondatalab.de/').toString();
        console.log('Visiting', url);
        await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
        const safeName = p.replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '') || 'page';
        await page.screenshot({ path: `${outDir}/desktop-${safeName}.png`, fullPage: false });
      } catch (e) {
        console.error('Failed to capture', p, e.message || e);
      }
    }

    console.log('DONE');
  } catch (err) {
    console.error('ERROR', err);
    process.exitCode = 2;
  } finally {
    await browser.close();
  }
})();
