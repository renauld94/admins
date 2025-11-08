# Geospatial Viz (EPIC Geodashboard)

This folder contains a lightweight 3D globe demo built with Three.js and an ES-module-based workflow.

Quick commands (development)

- Serve the folder locally:

```bash
cd portfolio-deployment-enhanced/geospatial-viz
python3 -m http.server 9000
# open http://localhost:9000/globe-3d-threejs.html
```

Build (production)

```bash
cd portfolio-deployment-enhanced/geospatial-viz
npm ci
npm run build
```

This will produce `dist/globe-bundle.js` and copy the texture `dist/earth_day.jpg`.

CI Smoke Test

We include a Playwright-based headless test at `ci/headless_capture.py` which is used by the GitHub Actions workflow `.github/workflows/ci_playwright.yml`.

Notes
- The project uses an import map in `globe-3d-threejs.html` to resolve the bare specifier `three` for example modules. For production we bundle with esbuild to avoid relying on import maps.
- Large textures should be hosted as static assets (CDN or release artifacts) rather than committed to git. Consider using Git LFS for large binaries.
