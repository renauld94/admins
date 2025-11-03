const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  // Use Google Chrome executable
  const chromePaths = [
    '/usr/bin/google-chrome',
    '/usr/bin/chromium-browser',
    '/usr/bin/chromium',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    'C:/Program Files/Google/Chrome/Application/chrome.exe'
  ];
  let chromePath = chromePaths.find(p => require('fs').existsSync(p));
  if (!chromePath) {
    console.error('Google Chrome executable not found. Please install Chrome or specify the path.');
    process.exit(1);
  }

  const browser = await puppeteer.launch({
    headless: false,
    executablePath: chromePath,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  // Go to OpenWebUI login page
  await page.goto('https://openwebui.simondatalab.de/', { waitUntil: 'networkidle2' });

  // Enter your email and submit
  await page.type('input[type="email"]', 'sn.renauld@gmail.com');
  await page.click('button[type="submit"]');

  console.log('Please check your email, enter the verification code in the browser, and wait for the OpenWebUI dashboard to load.');


  // Manual pause: wait for user to press Enter after login
  const readline = require('readline');
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  console.log('\nAfter you finish login in the browser, press Enter here to continue...');
  await new Promise(resolve => rl.question('', () => { rl.close(); resolve(undefined); }));

  // Get Cloudflare Access cookie
  const cookies = await page.cookies();
  const cfCookie = cookies.find(c => c.name.startsWith('CF_Authorization'));
  if (!cfCookie) {
    console.error('Cloudflare Access cookie not found. Login may have failed.');
    await browser.close();
    process.exit(1);
  }

  console.log(`\nYour Cloudflare Access cookie:\n${cfCookie.name}=${cfCookie.value}\n`);

  // Fetch models using the cookie
  const response = await page.goto('https://openwebui.simondatalab.de/api/models', { waitUntil: 'networkidle2' });
  const models = await response.text();
  console.log('Models API response:\n', models);

  await browser.close();
})();