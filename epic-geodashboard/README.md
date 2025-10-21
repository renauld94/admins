# Epic Geospatial Dashboard

This small dashboard is a mobile/desktop-ready visualization built with Leaflet, Plotly, and D3. It includes a local proxy to access a GeoServer instance running on your Proxmox VM (VM 106) to avoid CORS issues.

Quick start

1. Create a Python venv and install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

1. Start the proxy (defaults to 127.0.0.1:8001):

```bash
python proxy.py --host 127.0.0.1 --port 8001
```

1. Update `main.js` WMS URL to point at the proxy, e.g.:

```js
const wmsUrl = 'http://127.0.0.1:8001/wms?';
```

1. Open `index.html` in a browser or host it via a simple static server (recommended):

```bash
python -m http.server 8080
# then visit http://localhost:8080/epic-geodashboard/index.html
```

## Security notes

- The proxy restricts allowed hosts in `ALLOWED_HOSTS`. If you run this in a network, ensure proper firewalling and authentication.
- Do not expose this service publicly without adding auth.

## Assets

Place any GeoJSON or assets into `assets/` (e.g. `assets/sample-nodes.geojson`) to auto-load into the map.

## Optional: run proxy + tunnel as services (systemd)

If you'd like the SSH tunnel and proxy to run persistently on a Linux host, copy the unit files in `systemd/` to `/etc/systemd/system/` and enable them.

Example (run as root or with sudo):

```bash
# install unit files
sudo cp systemd/autossh-tunnel.service /etc/systemd/system/
sudo cp systemd/epic-proxy.service /etc/systemd/system/

# reload systemd and start
sudo systemctl daemon-reload
sudo systemctl enable --now autossh-tunnel.service
sudo systemctl enable --now epic-proxy.service

# check status
sudo systemctl status autossh-tunnel.service epic-proxy.service
journalctl -u autossh-tunnel.service -f
journalctl -u epic-proxy.service -f
```

Notes:

- Ensure key-based SSH auth is configured for `simonadmin@136.243.155.166` before enabling the tunnel, otherwise the tunnel will fail to start.
- The tunnel forwards `127.0.0.1:9002` on the local host to `127.0.0.1:8080` on the remote host — adjust `autossh-tunnel.service` if GeoServer is at a different address/port.
- `epic-proxy.service` uses the venv python inside the project; ensure the venv is created and dependencies installed.
