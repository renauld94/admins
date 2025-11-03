const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('https://www.simondatalab.de', { waitUntil: 'networkidle2', timeout: 90000 });

  // Impact metrics
  const metrics = await page.$$eval('.impact-metrics li', els => els.map(el => el.textContent.trim()));
  console.log('Impact Metrics:', metrics);

  // Credibility footnote
  let footnote = '';
  try {
    footnote = await page.$eval('.metrics-footnote', el => el.textContent.trim());
  } catch (e) {
    footnote = 'Footnote not found';
  }
  console.log('Footnote:', footnote);

  // Navigation links
  const navLinks = await page.$$eval('.nav-link', els => els.map(el => el.href));
  console.log('Navigation Links:', navLinks);

  // Screenshot for visual QA
  await page.screenshot({ path: 'homepage.png', fullPage: true });

  // Accessibility: check for skip link and ARIA labels
  const skipLink = await page.$('a.skip-link');
  const hasSkipLink = !!skipLink;
  const ariaLabels = await page.$$eval('[aria-label]', els => els.map(el => el.getAttribute('aria-label')));
  console.log('Has skip link:', hasSkipLink);
  console.log('ARIA labels:', ariaLabels);

  // Mobile emulation test
  await page.setViewport({ width: 375, height: 812 });
  await page.screenshot({ path: 'homepage-mobile.png', fullPage: true });

  await browser.close();
})();
