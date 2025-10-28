const { devices } = require('@playwright/test');

/** @type {import('@playwright/test').PlaywrightTestConfig} */
module.exports = {
  testDir: './tests/playwright',
  timeout: 30 * 1000,
  retries: 0,
  use: {
    headless: true,
    viewport: { width: 390, height: 844 },
    actionTimeout: 5 * 1000,
    baseURL: 'http://localhost:8000'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['iPhone 12'], browserName: 'chromium' },
    }
  ]
};
