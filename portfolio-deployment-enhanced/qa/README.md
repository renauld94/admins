# QA harness

This folder contains a small Puppeteer-based smoke test used to verify the portfolio visualization start-up.

Commands

Install dependencies:

```bash
cd qa
npm ci
```

Run the test locally (default URL is https://www.simondatalab.de/):

```bash
node test.js https://www.simondatalab.de/
```

Outputs are written to `qa/output/` (screenshots and console JSON). The CI workflow uploads these as artifacts.
