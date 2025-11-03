// Render the MCP one‑pager HTML to a single‑page A4 PDF using Puppeteer
// Output: linkedin-automation/outputs/MCP_Agents_Continue_OnePager.pdf

const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

(async () => {
  const root = path.resolve(__dirname, '..');
  const outDir = path.join(root, 'outputs');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  const htmlPath = path.resolve(__dirname, 'onepager.html');
  const pdfPath = path.join(outDir, 'MCP_Agents_Continue_OnePager.pdf');

  const browser = await puppeteer.launch({
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--font-render-hinting=medium'
    ]
  });
  const page = await browser.newPage();

  await page.goto('file://' + htmlPath, { waitUntil: 'networkidle0' });

  await page.pdf({
    path: pdfPath,
    format: 'A4',
    printBackground: true,
    margin: { top: '12mm', bottom: '12mm', left: '10mm', right: '10mm' }
  });

  await browser.close();
  console.log('✅ PDF generated at:', pdfPath);
})();
