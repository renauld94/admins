const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

const URL = process.argv[2] || 'https://www.simondatalab.de/';
const OUT_DIR = path.resolve(__dirname, 'output');
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

async function runViewport(name, viewport, emulateMobile = false) {
  const logs = [];
  const browser = await puppeteer.launch({ headless: 'new' });
  try {
    const page = await browser.newPage();
    if (emulateMobile) {
      await page.setViewport(viewport);
      // a simple mobile UA
      await page.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15A372 Safari/604.1');
    } else {
      await page.setViewport(viewport);
    }

    page.on('console', msg => {
      try {
        const text = msg.text();
        const type = msg.type();
        const entry = { type, text, location: msg.location() };
        logs.push(entry);
      } catch (e) {
        logs.push({ type: 'error', text: 'console parse error' });
      }
    });

  // navigate and wait for network idle (timeout configurable via NAV_TIMEOUT env var)
  const NAV_TIMEOUT = parseInt(process.env.NAV_TIMEOUT, 10) || 60000;
  const WAIT_UNTIL = process.env.WAIT_UNTIL || 'load';
  // Post-navigation wait (ms) - allow the page some breathing room for loader polling
  const POST_WAIT_MS = parseInt(process.env.POST_WAIT_MS, 10) || 3000;
  // Use 'load' by default to avoid networkidle issues with long-polling resources on the page
  await page.goto(URL, { waitUntil: WAIT_UNTIL, timeout: NAV_TIMEOUT });

    // give extra time for loader polling (three-loader waits up to ~350ms per source)
    await page.waitForTimeout(POST_WAIT_MS);

    const shotPath = path.join(OUT_DIR, `screenshot-${name}.png`);
    await page.screenshot({ path: shotPath, fullPage: false });

    // filter logs for interesting entries
  const interesting = logs.filter(l => /OrbitControls|three-loader|threeJsReady|globe-3d|THREE|orbitcontrols|NEURAL|neural/i.test(l.text));

    const out = {
      url: URL,
      viewport: { name, viewport, emulateMobile },
      screenshot: shotPath,
      totalConsole: logs.length,
      interesting: interesting.slice(0, 200)
    };

    const outPath = path.join(OUT_DIR, `console-${name}.json`);
    fs.writeFileSync(outPath, JSON.stringify(out, null, 2));

    console.log(`RESULT ${name}: screenshot -> ${shotPath}, console -> ${outPath}, total console messages: ${logs.length}`);
    if (interesting.length) {
      console.log(`--- interesting console lines (${interesting.length}) ---`);
      interesting.forEach((l,i) => console.log(`${i+1}. [${l.type}] ${l.text}`));
    } else {
      console.log('--- no interesting console lines matched ---');
    }

    await browser.close();
    return { ok: true };
  } catch (err) {
    await browser.close();
    console.error('Error during runViewport', err);
    return { ok: false, err: String(err) };
  }
}

(async () => {
  console.log('Starting headless QA for', URL);
  const desktop = await runViewport('desktop', { width: 1200, height: 800, deviceScaleFactor: 1 }, false);
  const mobile = await runViewport('mobile', { width: 375, height: 667, deviceScaleFactor: 2 }, true);
  console.log('Completed runs.');
  process.exit((desktop.ok && mobile.ok) ? 0 : 2);
})();
