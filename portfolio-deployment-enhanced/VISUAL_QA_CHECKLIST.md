Visual QA Checklist — Neuro DataLab

Follow these steps on desktop and mobile (recommended: Chrome or Safari mobile).
Mark each item PASS/FAIL and paste any console output or screenshots if anything fails.

1) Hero overlay
- What to check: The hero visualization should load without any centered textual loading overlay visible on top of the viz.
- How to check: Open the homepage, observe the hero area on load and after the viz finishes initialization.
- Expected: No large centered loading text; small spinner or subtle placeholder allowed only briefly.

2) Molecules / Particles
- What to check: Particle points should be circular (round) and not display square artifacts.
- How to check: Zoom in visually (DevTools device toolbar) and observe particles at 100%-200% zoom.
- Expected: Round molecules (canvas sprite or PointsMaterial.map applied) and visually smooth motion.

3) CTAs and keyboard focus
- What to check: Primary and secondary CTAs (`.btn--primary`, `.btn--secondary`) show expected styles and keyboard focus is visible.
- How to check: Tab through the page until the CTAs are focused; ensure focus ring/outline is visible.
- Expected: Visible, accessible focus style and correct colors/contrast on buttons.

4) Navigation behavior
- What to check: Desktop nav shows at wide widths (>= 993px) and mobile menu toggles correctly.
- How to check: Resize viewport to desktop and mobile widths; click menu toggle on mobile.
- Expected: Desktop `.desktop-nav` visible; mobile menu opens/closes, links are clickable.

5) Dev build badge
- What to check: Developer badge shows the deployed version/time when `?dev` is appended or devmode toggled.
- How to check: Visit `https://<your-site>/?dev` and check the dev badge in the nav (or toggle via localStorage if implemented).
- Expected: Badge displays JSON or human-readable version and build_time (e.g., a10d8bdd7-perf1 / 2025-10-30T06:58:00Z).

6) Console & performance notes
- What to check: DevTools Console should show initialization logs but no uncaught exceptions. Note any [Violation] lines that indicate heavy handlers.
- How to check: Open DevTools → Console and observe initialization logs (Three.js, viz modules). Interact with the viz lightly.
- Expected: No fatal errors. You may see a short [Violation] message; we reduced long idle callbacks. Report any persistent frame drops or stutters.

Optional: Quick accessibility spot checks
- Use browser default contrast tools or the installed aXe/Lighthouse plugin to run a quick audit.
- Verify forms (contact form) have labels and aria attributes.

Notes for reporting issues
- If FAIL on any item, copy the console output and note device/OS/browser/version and a screenshot of the failing area.
- For visual particle issues, include a 2x zoom screenshot focused on the hero viz.

Completed by: ____________________
Date: ____________________

