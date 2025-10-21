const { chromium, devices } = require('playwright');

(async () => {
  const iPhone = devices['iPhone 12'];
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ ...iPhone });
  const page = await context.newPage();

  const base = 'https://www.simondatalab.de/';
  console.log('Opening', base);
  await page.goto(base, { waitUntil: 'domcontentloaded', timeout: 30000 });

  // Wait for mobile menu button
  const menuBtn = await page.waitForSelector('.mobile-menu-btn', { timeout: 10000 });
  if (!menuBtn) throw new Error('mobile-menu-btn not found');
  console.log('mobile-menu-btn found');

  // Click the hamburger
  await menuBtn.click({ force: true });
  // Wait for mobile-nav to become active
  try {
    await page.waitForSelector('.mobile-nav.active', { timeout: 5000 });
    console.log('Mobile nav opened (active)');
  } catch (e) {
    // Try aria-hidden attribute
    const nav = await page.$('.mobile-nav');
    const hidden = await nav.getAttribute('aria-hidden');
    if (hidden === 'false') {
      console.log('Mobile nav opened (aria-hidden=false)');
    } else {
      throw new Error('Mobile nav did not open');
    }
  }

  // Click backdrop to close
  const backdrop = await page.$('#mobile-nav-backdrop, .mobile-nav-backdrop');
  if (backdrop) {
    await backdrop.click({ force: true });
    // ensure mobile-nav is not active
    try {
      await page.waitForSelector('.mobile-nav.active', { state: 'detached', timeout: 5000 });
      console.log('Mobile nav closed after backdrop click');
    } catch (e) {
      const nav = await page.$('.mobile-nav');
      const hidden = await nav.getAttribute('aria-hidden');
      if (hidden === 'true') {
        console.log('Mobile nav closed (aria-hidden=true)');
      } else {
        throw new Error('Mobile nav did not close');
      }
    }
  } else {
    console.log('No backdrop element found; skipping backdrop click');
  }

  // Find the infra thumbnail button
  const infraBtn = await page.$('[data-action="open-infra"]');
  if (!infraBtn) throw new Error('Infra thumbnail button [data-action="open-infra"] not found');
  console.log('Infra thumbnail found');

  // Prepare to catch a new page (popup) or navigation
  let newPagePromise = context.waitForEvent('page').catch(() => null);
  await infraBtn.click({ force: true });

  // Wait a short moment for popup to open
  const popup = await Promise.race([
    newPagePromise,
    new Promise(res => setTimeout(() => res(null), 1500))
  ]);

  let finalUrl = null;
  if (popup) {
    await popup.waitForLoadState('load');
    finalUrl = popup.url();
    console.log('Popup opened with URL:', finalUrl);
  } else {
    // No popup; check current page URL
    await page.waitForLoadState('load');
    finalUrl = page.url();
    console.log('Navigation to URL:', finalUrl);
  }

  const expected = 'https://www.simondatalab.de/geospatial-viz/index.html';
  if (!finalUrl.startsWith(expected)) {
    throw new Error(`Viewer did not open expected URL. Got: ${finalUrl}`);
  }

  console.log('Infra viewer opened successfully (matches expected URL)');

  await browser.close();
  console.log('Test completed: PASS');
  process.exit(0);
})().catch(err => {
  console.error('Test FAILED:', err);
  process.exit(2);
});
