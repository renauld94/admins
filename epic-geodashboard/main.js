// Leaflet map initialization
const map = L.map('mapid', {zoomControl:false}).setView([10.762622, 106.660172], 5); // Default: Ho Chi Minh City
L.control.zoom({ position: 'topright' }).addTo(map);
const osm = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

// Marker for VM location
const vmMarker = L.marker([10.762622, 106.660172]).addTo(map)
  .bindPopup('Proxmox VM 106 - GeoServer');
// map open popup only when clicked to reduce noise

// GeoServer WMS layer stub (uses VM 136.243.155.166:8080 or proxmox host)
let geoWms;
function addGeoServerWMS() {
  const wmsUrl = 'http://127.0.0.1:8002/wms?'; // proxy to GeoServer (run proxy.py) -> forwards to VM106
  geoWms = L.tileLayer.wms(wmsUrl, {
    layers: 'workspace:layername',
    format: 'image/png',
    transparent: true,
    attribution: 'GeoServer (VM106)'
  });
  // Do not add automatically; controlled by sidebar toggle
}
addGeoServerWMS();

// Plotly example chart
Plotly.newPlot('plotly-chart', [{
  x: ['Node A', 'Node B', 'Node C'],
  y: [25, 109, 558],
  type: 'bar',
  marker: {color: '#1a73e8'}
}], {
  title: 'Network Statistics',
  yaxis: {title: 'Value'},
  xaxis: {title: 'Node'}
});

// D3.js example analytics
const d3Div = d3.select('#d3-analytics');
d3Div.append('h3').text('Active Nodes');
d3Div.append('p').text('25');
d3Div.append('h3').text('Data Connections');
d3Div.append('p').text('109');
d3Div.append('h3').text('Data Volume (TB)');
d3Div.append('p').text('558');
d3Div.append('h3').text('Uptime (%)');
d3Div.append('p').text('99.9');

// Mobile menu toggle
const menuToggle = document.getElementById('menu-toggle');
const mainMenu = document.getElementById('main-menu');
menuToggle.addEventListener('click', () => {
  mainMenu.classList.toggle('open');
});

// Accessibility: close menu on Escape
window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') mainMenu.classList.remove('open');
});

// Sidebar controls wiring
const closeSidebar = document.getElementById('close-sidebar');
const sidebar = document.getElementById('control-sidebar');
closeSidebar.addEventListener('click', () => sidebar.setAttribute('aria-hidden', 'true'));

// connections toggle
document.getElementById('toggle-connections').addEventListener('change', (e) => {
  const on = e.target.checked;
  // For now toggle a demo polyline
  if (on) {
    demoConnectionsLayer.addTo(map);
  } else {
    map.removeLayer(demoConnectionsLayer);
  }
});

// labels toggle
document.getElementById('toggle-labels').addEventListener('change', (e) => {
  const on = e.target.checked;
  vmMarker.bindTooltip(on ? 'Proxmox VM 106' : '', {permanent: on}).openTooltip();
});

// weather toggle
document.getElementById('toggle-weather').addEventListener('change', (e) => {
  const on = e.target.checked;
  if (on) {
    // Note: OpenWeatherMap or other tile overlay may require API key
    weatherLayer.addTo(map);
  } else {
    map.removeLayer(weatherLayer);
  }
});

// weather opacity
document.getElementById('weather-opacity').addEventListener('input', (e) => {
  const v = e.target.value/100;
  if (weatherLayer) weatherLayer.setOpacity(v);
});

// region focus
document.getElementById('region-focus').addEventListener('change', (e) => {
  const v = e.target.value;
  if (v === 'vietnam') map.setView([10.762622, 106.660172], Number(document.getElementById('zoom-level').value));
  if (v === 'europe') map.setView([50.1109, 8.6821], Number(document.getElementById('zoom-level').value));
  if (v === 'global') map.setView([20,0], Number(document.getElementById('zoom-level').value));
});

// zoom level
document.getElementById('zoom-level').addEventListener('input', (e) => map.setZoom(Number(e.target.value)));

// demo connections layer (polyline)
const demoConnectionsLayer = L.layerGroup();
const poly = L.polyline([[10.76,106.66],[21.03,105.85],[16.07,108.22]], {color:'#73b3e9'}).addTo(demoConnectionsLayer);

// demo weather layer (simple tile overlay placeholder)
const weatherLayer = L.tileLayer('https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=YOUR_API_KEY', {opacity:0.7, attribution:'Weather: OpenWeatherMap'});

// services status panel: ping endpoints (note: requires CORS or proxy)
const services = [
  {name:'Grafana', url:'https://grafana.simondatalab.de/'},
  {name:'Prometheus', url:'https://prometheus.simondatalab.de/'},
  {name:'MLflow', url:'https://mlflow.simondatalab.de/'},
  {name:'Proxmox', url:'https://136.243.155.166:8006/'}
];

async function checkService(url, timeout=5000) {
  try {
    // Use the proxy endpoint to avoid CORS and use GET
    const proxyUrl = `/proxy?url=${encodeURIComponent(url)}`;
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);
    const res = await fetch(proxyUrl, {method:'GET', signal: controller.signal});
    clearTimeout(id);
    return {ok: res.ok, status: res.status};
  } catch (err) {
    return {ok:false, error:err.message};
  }
}

// create services panel UI
function renderServicesPanel() {
  const container = document.createElement('div');
  container.className='services-panel';
  const ul = document.createElement('ul');
  ul.style.listStyle='none'; ul.style.padding='0';
  services.forEach(s => {
    const li = document.createElement('li');
    li.style.marginBottom='8px';
    const a = document.createElement('a');
    a.href = s.url; a.target='_blank'; a.rel='noopener';
    a.textContent = s.name;
    const badge = document.createElement('span');
    badge.textContent = 'Checking...'; badge.style.marginLeft='8px'; badge.style.color='#c0cde6';
    li.appendChild(a); li.appendChild(badge); ul.appendChild(li);
    checkService(s.url).then(result => { badge.textContent = result.ok ? `UP (${result.status})` : `DOWN`; badge.style.color = result.ok ? '#7beaa1' : '#ff6b6b'; }).catch(()=>{ badge.textContent='UNKNOWN'; });
  });
  container.appendChild(ul);
  document.getElementById('services').appendChild(container);
}
renderServicesPanel();

// Attempt to load local GeoJSON assets if present
async function tryLoadLocalGeoJSON(name) {
  try {
    const res = await fetch(`assets/${name}`);
    if (!res.ok) throw new Error('not found');
    const geo = await res.json();
    L.geoJSON(geo, {style(){ return {color:'#1a73e8'} }}).addTo(map);
    console.log('Loaded local asset', name);
  } catch (err) {
    console.log('Local asset missing:', name);
  }
}
tryLoadLocalGeoJSON('sample-nodes.geojson');

// finalize: ensure demo connections layer added initially
demoConnectionsLayer.addTo(map);
