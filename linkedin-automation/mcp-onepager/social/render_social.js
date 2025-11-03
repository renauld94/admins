// Render LinkedIn visuals (1350x1080) as PNGs using Puppeteer
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

async function render(url, outPath){
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox','--disable-setuid-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 1350, height: 1080, deviceScaleFactor: 2 });
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.screenshot({ path: outPath, type: 'png' });
  await browser.close();
}

(async () => {
  const base = path.resolve(__dirname);
  const outDir = path.resolve(__dirname, '../../outputs/social');
  const outCarousel = path.join(outDir, 'carousel');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  if (!fs.existsSync(outCarousel)) fs.mkdirSync(outCarousel, { recursive: true });

  // Single
  const single = path.join(base, 'single.html');
  await render('file://' + single, path.join(outDir, 'MCP_Agents_Continue_1350x1080.png'));

  // Carousel slides
  const slides = [
    'slides/slide-01.html',
    'slides/slide-02.html',
    'slides/slide-03.html',
    'slides/slide-04.html',
    'slides/slide-05.html',
  ];
  for (let i=0;i<slides.length;i++){
    const url = 'file://' + path.join(base, slides[i]);
    const out = path.join(outCarousel, `slide-${String(i+1).padStart(2,'0')}.png`);
    await render(url, out);
  }
  console.log('✅ Rendered LinkedIn assets to:', outDir);
})();
