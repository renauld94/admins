const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const out = 'deploy/screenshots';
  if (!fs.existsSync(out)) fs.mkdirSync(out, { recursive: true });

  const browser = await chromium.launch();
  try {
    const page = await browser.newPage({ viewport: { width: 1366, height: 768 } });
    console.log('Navigating (desktop)...');
    await page.goto('https://www.simondatalab.de/infrastructure-diagram.html?full=1', { waitUntil: 'networkidle', timeout: 30000 });
    await page.screenshot({ path: `${out}/infra-desktop-after.png`, fullPage: false });
    console.log('Desktop screenshot saved');

    await page.setViewportSize({ width: 375, height: 812 });
    console.log('Reloading for mobile viewport...');
    await page.reload({ waitUntil: 'networkidle', timeout: 30000 });
    await page.screenshot({ path: `${out}/infra-mobile-after.png`, fullPage: false });
    console.log('Mobile screenshot saved');

  } catch (e) {
    console.error('Capture failed', e);
    process.exitCode = 2;
  } finally {
    await browser.close();
  }
  console.log('CAPTURE_DONE');
})();
