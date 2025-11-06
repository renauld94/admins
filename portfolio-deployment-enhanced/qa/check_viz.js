#!/usr/bin/env node
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
      heroFound: !!hero,
      heroVisible: hero ? (()=>{const r=hero.getBoundingClientRect(); const s=getComputedStyle(hero); return r.width>0 && r.height>0 && s.display!=='none' && s.visibility!=='hidden';})() : false,
      canvasesInHero: canvases,
      hasEpicClass: !!window.EpicNeuralToCosmosViz,
      hasSimpleClass: !!window.SimpleNeuralViz,
      hasGeoServerClass: !!window.NeuralGeoServerViz,
      epicVizExists: !!window.epicNeuralViz,
      autoloadFlag: window.__ALLOW_NEURAL_AUTOLOAD__
    };
  });
  console.log('INFO', JSON.stringify(info, null, 2));
  console.log('CONSOLE_COUNT:', logs.length);
  console.log('LAST_15_LOGS:', JSON.stringify(logs.slice(-15), null, 2));
  await browser.close();
})().catch(err => { console.error(err); process.exit(1); });
