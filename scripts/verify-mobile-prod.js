const { chromium, devices } = require('playwright');
const fs = require('fs');
(async () => {
  const outDir = 'deploy/screenshots';
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const iPhone = devices['iPhone 12'];
  const browser = await chromium.launch();
  const context = await browser.newContext({ ...iPhone });
  const page = await context.newPage();

  page.on('console', msg => console.log('PAGE_LOG>', msg.text()));
  page.on('pageerror', err => console.error('PAGE_ERROR>', err));

  try {
    console.log('Mobile emulation: iPhone 12 -> Navigating to https://www.simondatalab.de/ ...');
    await page.goto('https://www.simondatalab.de/', { waitUntil: 'networkidle', timeout: 30000 });
    console.log('Taking mobile hero screenshot...');
    await page.screenshot({ path: `${outDir}/mobile-hero.png`, fullPage: false });

    const navButton = await page.$('.mobile-menu-btn');
    if (navButton) {
      const visible = await navButton.isVisible();
      if (visible) {
        console.log('Found visible .mobile-menu-btn on mobile, toggling...');
        await navButton.click();
        await page.waitForTimeout(500);
        await page.screenshot({ path: `${outDir}/mobile-nav-open.png` });
        // Verify nav links visible
        const links = await page.$$eval('.mobile-nav .nav-link, #mobile-navigation .nav-link, .mobile-nav a', els => els.map(e => ({ text: e.textContent && e.textContent.trim(), visible: window.getComputedStyle(e).display !== 'none' })));
        console.log('Mobile nav links sample:', links.slice(0,6));
        await navButton.click();
        await page.waitForTimeout(200);
        await page.screenshot({ path: `${outDir}/mobile-nav-closed.png` });
      } else {
        console.log('.mobile-menu-btn present but not visible on mobile (unexpected)');
        await page.screenshot({ path: `${outDir}/mobile-no-mobile-btn-visible.png` });
      }
    } else {
      console.log('No .mobile-menu-btn in DOM on mobile (unexpected)');
      await page.screenshot({ path: `${outDir}/mobile-no-mobile-btn-dom.png` });
    }

    // capture a couple more important pages in mobile emulation
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
        await page.screenshot({ path: `${outDir}/mobile-${safeName}.png`, fullPage: false });
      } catch (e) {
        console.error('Failed to capture', p, e.message || e);
      }
    }

    console.log('MOBILE DONE');
  } catch (err) {
    console.error('ERROR', err);
    process.exitCode = 2;
  } finally {
    await browser.close();
  }
})();
