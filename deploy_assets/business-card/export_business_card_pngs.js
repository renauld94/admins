// Automated script to export high-quality PNGs of business card front and back using Puppeteer
// Usage: node export_business_card_pngs.js

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

(async () => {
  const htmlPath = path.resolve(__dirname, 'business-card.html');
  const fileUrl = 'file://' + htmlPath;
  const outputDir = path.resolve(__dirname, 'output');
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

  const browser = await puppeteer.launch({ headless: true, defaultViewport: null });
  const page = await browser.newPage();

  // Set a large viewport for print quality (e.g., 1920x1080 or higher)
  await page.setViewport({ width: 1920, height: 1080, deviceScaleFactor: 3 });

  await page.goto(fileUrl, { waitUntil: 'networkidle0' });


  // Wait for the card element to be present
  // Try common selectors, adjust as needed
  const cardSelector = '.business-card, #business-card, .card, .container, main';
  await page.waitForSelector(cardSelector, { timeout: 5000 });

  // Get all matching elements (front and back)
  const cardElements = await page.$$(cardSelector);
  if (cardElements.length === 0) {
    throw new Error('No card elements found. Please check the selector.');
  }

  // Screenshot the first card (front)
  await cardElements[0].screenshot({
    path: path.join(outputDir, 'business-card-front.png')
  });

  // If there is a second card (back), screenshot it
  if (cardElements.length > 1) {
    await cardElements[1].screenshot({
      path: path.join(outputDir, 'business-card-back.png')
    });
  } else {
    // If not, try scrolling or switching to the back manually
    // For now, fallback to previous method (scroll and screenshot viewport)
    await page.evaluate(() => window.scrollTo(0, window.innerHeight));
    await page.waitForTimeout(1000);
    await page.screenshot({
      path: path.join(outputDir, 'business-card-back.png'),
      fullPage: false
    });
  }

  await browser.close();
  console.log('PNGs exported to', outputDir);
})();
