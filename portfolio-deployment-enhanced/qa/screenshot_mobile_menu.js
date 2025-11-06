const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 393, height: 851, deviceScaleFactor: 2, isMobile: true, hasTouch: true });
  await page.goto('https://www.simondatalab.de/?cb=menu' + Date.now(), { waitUntil: 'networkidle2' });
  await page.waitForTimeout(2000);
  await page.click('.mobile-menu-btn');
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'reports/mobile_menu_open.png', fullPage: false });
  const info = await page.evaluate(() => {
    const results = [];
    const selectors = ['.mobile-nav', '#mobile-navigation', '.mobile-nav-menu', '.nav-link'];
    selectors.forEach(sel => {
      const els = document.querySelectorAll(sel);
      els.forEach((el, i) => {
        const s = window.getComputedStyle(el);
        results.push({
          selector: sel + '_' + i,
          bg: s.backgroundColor,
          color: s.color,
          text: el.textContent ? el.textContent.trim().substring(0, 30) : ''
        });
      });
    });
    return results;
  });
  console.log(JSON.stringify(info, null, 2));
  await browser.close();
})().catch(console.error);
