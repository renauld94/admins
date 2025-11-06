const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 393, height: 851, deviceScaleFactor: 2, isMobile: true, hasTouch: true });
  await page.goto('https://www.simondatalab.de/?fix=' + Date.now(), { waitUntil: 'networkidle2' });
  await page.waitForTimeout(2000);
  await page.click('.mobile-menu-btn');
  await page.waitForTimeout(800);
  
  const colors = await page.evaluate(() => {
    const toggle = document.querySelector('.mobile-dropdown-toggle');
    const link = document.querySelector('.mobile-nav-menu .nav-link');
    const dropdownLink = document.querySelector('.mobile-dropdown-menu .nav-link');
    
    return {
      toggle: toggle ? window.getComputedStyle(toggle).color : 'not found',
      link: link ? window.getComputedStyle(link).color : 'not found',
      dropdownLink: dropdownLink ? window.getComputedStyle(dropdownLink).color : 'not found (dropdown closed)'
    };
  });
  
  console.log('Mobile menu text colors:');
  console.log(JSON.stringify(colors, null, 2));
  console.log('\nExpected: All should be rgb(15, 23, 42) - dark text');
  await browser.close();
})().catch(console.error);
