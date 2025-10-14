Playwright Automation for Moodle Import

This script automates the final 5-minute UI steps to import the lesson into Moodle:
- Login as admin
- Import Moodle XML quiz
- Create lesson page and paste HTML iframe
- Create quiz activity and add questions

Prerequisites
- Node.js 18+
- Install dependencies: `npm install` (in the `automation/playwright` folder)

Environment variables
- `MOODLE_ADMIN_PASS` - required (admin password)
- `MOODLE_ADMIN_USER` - default `admin`
- `MOODLE_URL` - default `https://moodle.simondatalab.de`

Run

```bash
cd automation/playwright
npm install
MOODLE_ADMIN_PASS="<your-password>" node import_moodle.js
```

Notes
- The script runs in headed mode (headless: false) so you can watch the actions and intervene if theme variations require tweaks.
- Playwright selectors are best-effort and may require small adjustments if your Moodle theme differs from standard Boost.
- This is the recommended approach if you want full automation for many lessons; otherwise use the 5-minute UI steps in `QUICK_IMPORT_GUIDE.md`.
