const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 393, height: 851, deviceScaleFactor: 2, isMobile: true, hasTouch: true });
  await page.goto('https://www.simondatalab.de/?cb=menu' + Date.now(), { waitUntil: 'networkidle2' });
  await page.waitForTimeout(2000);
  
  // Click the mobile menu button
  await page.click('.mobile-menu-btn');
  await page.waitForTimeout(500);
  
  const styles = await page.evaluate(() => {
    const nav = document.querySelector('.mobile-nav') || document.querySelector('#mobile-navigation');
    const link = document.querySelector('.mobile-nav-menu .nav-link') || document.querySelector('.mobile-nav .nav-link');
    const navStyles = nav ? window.getComputedStyle(nav) : null;
    const linkStyles = link ? window.getComputedStyle(link) : null;
    
    return {
      navBackground: navStyles?.backgroundColor,
      navColor: navStyles?.color,
      linkColor: linkStyles?.color,
      linkBackground: linkStyles?.backgroundColor,
      navVisible: navStyles?.visibility,
      navTransform: navStyles?.transform
    };
  });
  
  console.log(JSON.stringify(styles, null, 2));
  await browser.close();
})().catch(console.error);
