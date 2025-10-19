/* Geodashboard app: MapLibre + optional GeoServer WMS overlay */
(function () {
  const map = new maplibregl.Map({
    container: 'map',
    style: {
      version: 8,
      name: 'OSM Light',
      sources: {
        osm: {
          type: 'raster',
          tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
          tileSize: 256,
          attribution: '© OpenStreetMap contributors'
        },
        carto_dark: {
          type: 'raster',
          tiles: ['https://cartodb-basemaps-b.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'],
          tileSize: 256,
          attribution: '© CARTO'
        }
      },
      layers: [
        { id: 'osm_base', type: 'raster', source: 'osm', minzoom: 0, maxzoom: 19, layout: { visibility: 'visible' } }
      ]
    },
    center: [106.6297, 10.8231], // Ho Chi Minh City
    zoom: 5,
    attributionControl: true
  });

  // UI elements
  const basemapSelect = document.getElementById('basemapSelect');
  const gsToggle = document.getElementById('gsToggle');
  const gsOpacity = document.getElementById('gsOpacity');
  const gsOpacityValue = document.getElementById('gsOpacityValue');
  const cfgService = document.getElementById('cfgService');
  const cfgLayer = document.getElementById('cfgLayer');
  const cfgCrs = document.getElementById('cfgCrs');

  const panelToggle = document.getElementById('panelToggle');
  const panelBody = document.getElementById('panelBody');

  // Metrics UI
  const metricsEndpoint = document.getElementById('metricsEndpoint');
  const metricsRefresh = document.getElementById('metricsRefresh');
  const metricsStatus = document.getElementById('metricsStatus');
  const metricsUp = document.getElementById('metricsUp');
  const metricsDown = document.getElementById('metricsDown');

  // Toggle panel
  panelToggle.addEventListener('click', () => {
    const isOpen = panelBody.style.display !== 'none';
    panelBody.style.display = isOpen ? 'none' : 'block';
    panelToggle.textContent = isOpen ? '▸' : '▾';
    panelToggle.setAttribute('aria-expanded', String(!isOpen));
  });

  // Basemap switching
  basemapSelect.addEventListener('change', () => {
    const val = basemapSelect.value;
    const current = map.getStyle();

    // Ensure layers exist once the style is loaded
    if (!map.getSource('carto_dark')) {
      map.addSource('carto_dark', current.sources['carto_dark']);
    }

    if (!map.getLayer('carto_dark_base')) {
      map.addLayer({ id: 'carto_dark_base', type: 'raster', source: 'carto_dark', minzoom: 0, maxzoom: 19, layout: { visibility: 'none' } }, 'osm_base');
    }

    const showOsm = val === 'osm_light';
    map.setLayoutProperty('osm_base', 'visibility', showOsm ? 'visible' : 'none');
    map.setLayoutProperty('carto_dark_base', 'visibility', showOsm ? 'none' : 'visible');
  });

  // Optional GeoServer WMS overlay
  const gsConfig = {
    // Adjust to your GeoServer endpoint if available
    serviceUrl: '', // e.g., 'https://geoserver.simondatalab.de/geoserver/wms'
    layerName: '', // e.g., 'workspace:admin_boundaries'
    params: {
      service: 'WMS', request: 'GetMap', version: '1.1.1', format: 'image/png', transparent: 'true', srs: 'EPSG:3857'
    }
  };

  cfgService.textContent = gsConfig.serviceUrl || 'Not configured';
  cfgLayer.textContent = gsConfig.layerName || 'Not configured';

  let gsSourceId = 'geoserver_wms';
  let gsLayerId = 'geoserver_wms_layer';

  function buildWmsUrl(bbox) {
    const { serviceUrl, layerName, params } = gsConfig;
    if (!serviceUrl || !layerName) return '';
    const query = new URLSearchParams({ ...params, layers: layerName, bbox: bbox.join(','), width: 256, height: 256 });
    return `${serviceUrl}?${query.toString()}`;
  }

  function ensureGsLayer() {
    if (!gsConfig.serviceUrl || !gsConfig.layerName) return false;

    if (!map.getSource(gsSourceId)) {
      map.addSource(gsSourceId, {
        type: 'raster',
        tiles: [
          // Templated URL: MapLibre replaces {bbox-epsg-3857}
          `${gsConfig.serviceUrl}?service=WMS&request=GetMap&version=1.1.1&layers=${encodeURIComponent(gsConfig.layerName)}&styles=&format=image/png&transparent=true&srs=EPSG:3857&width=256&height=256&bbox={bbox-epsg-3857}`
        ],
        tileSize: 256,
        attribution: 'GeoServer'
      });
    }
    if (!map.getLayer(gsLayerId)) {
      map.addLayer({ id: gsLayerId, type: 'raster', source: gsSourceId, paint: { 'raster-opacity': 1 } });
    }
    return true;
  }

  function setGsVisibility(visible) {
    if (!ensureGsLayer()) return;
    map.setLayoutProperty(gsLayerId, 'visibility', visible ? 'visible' : 'none');
  }

  function setGsOpacity(val) {
    if (!map.getLayer(gsLayerId)) return;
    map.setPaintProperty(gsLayerId, 'raster-opacity', val / 100);
  }

  gsToggle.addEventListener('change', () => {
    setGsVisibility(gsToggle.checked);
  });

  gsOpacity.addEventListener('input', () => {
    const v = parseInt(gsOpacity.value, 10);
    gsOpacityValue.textContent = `${v}%`;
    setGsOpacity(v);
  });

  // Inspector
  const lonEl = document.getElementById('inspLon');
  const latEl = document.getElementById('inspLat');
  const zoomEl = document.getElementById('inspZoom');

  function updateInsp() {
    const c = map.getCenter();
    lonEl.textContent = c.lng.toFixed(5);
    latEl.textContent = c.lat.toFixed(5);
    zoomEl.textContent = map.getZoom().toFixed(2);
  }

  map.on('load', () => {
    // Prepare alternate dark base layer (hidden by default)
    map.addLayer({ id: 'carto_dark_base', type: 'raster', source: 'carto_dark', layout: { visibility: 'none' } }, 'osm_base');
    updateInsp();
  });
  map.on('moveend', updateInsp);
  map.on('click', (e) => {
    lonEl.textContent = e.lngLat.lng.toFixed(5);
    latEl.textContent = e.lngLat.lat.toFixed(5);
  });

  // Accessibility: reduce motion
  if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    map.setPrefersReducedMotion(true);
  }

  // Metrics proxy helpers
  function baseUrl(u) {
    // Normalize: allow both https://host and https://host/metrics; always append path fragments properly
    try {
      const url = new URL(u);
      return url.toString().replace(/\/$/, '');
    } catch {
      return u;
    }
  }

  async function checkHealth(base) {
    const url = new URL('/health', baseUrl(base)).toString();
    const r = await fetch(url, { cache: 'no-store' });
    if (!r.ok) throw new Error('health failed');
    return r.json();
  }
  async function fetchTargets(base) {
    // Support proxies mounted at root or /metrics
    let url;
    try {
      url = new URL('/metrics/targets', baseUrl(base)).toString();
    } catch {
      url = `${base}/metrics/targets`;
    }
    const r = await fetch(url, { cache: 'no-store' });
    if (!r.ok) throw new Error('targets failed');
    return r.json();
  }
  function summarizeTargets(payload) {
    try {
      const active = payload.data.activeTargets || [];
      let up = 0, down = 0;
      for (const t of active) {
        if (t.health === 'up') up++; else down++;
      }
      return { up, down };
    } catch {
      return { up: 0, down: 0 };
    }
  }
  async function refreshMetrics() {
    const base = metricsEndpoint.value.trim();
    if (!base) {
      metricsStatus.textContent = 'Enter proxy endpoint';
      return;
    }
    metricsStatus.textContent = 'Connecting…';
    try {
      await checkHealth(base);
      const targets = await fetchTargets(base);
      const { up, down } = summarizeTargets(targets);
      metricsUp.textContent = String(up);
      metricsDown.textContent = String(down);
      metricsStatus.textContent = 'OK';
    } catch (e) {
      metricsStatus.textContent = 'Error';
    }
  }
  metricsRefresh.addEventListener('click', refreshMetrics);
})();
