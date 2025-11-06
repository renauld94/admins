const puppeteer = require('puppeteer');
(async () => {
  const url = process.env.TARGET_URL || 'https://www.simondatalab.de';
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox','--disable-setuid-sandbox'] });
  const page = await browser.newPage();
  const logs = [];
  page.on('console', msg => logs.push({type: msg.type(), text: msg.text()}));
  const mobile = process.env.MOBILE === '1';
  await page.setViewport(mobile ? { width: 393, height: 851, deviceScaleFactor: 2, isMobile: true, hasTouch: true } : { width: 1366, height: 900, deviceScaleFactor: 1 });
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 45000 });
  await page.waitForTimeout(8000); // Extended wait for deferred init
  const info = await page.evaluate(() => {
    const hero = document.querySelector('#hero-visualization');
    const canvases = hero ? hero.querySelectorAll('canvas').length : 0;
    return {
      heroFound: bash -lc cd
