"""
pull_open_datasets.py

Purpose:
- Search CKAN portals (data.gov.vn and OpenDevelopment Mekong) for fisheries / aquaculture datasets
- Download CSV / GeoJSON / Shapefile resources to ./data/fishing/<dataset-id>/
- Convert vector files to GeoJSON (EPSG:4326) when possible

Usage (recommended to run locally):
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    python scripts/pull_open_datasets.py --download --out data/fishing

Notes:
- Some portals (Global Fishing Watch, ProtectedPlanet) require registration or manual download.
- This script focuses on CKAN-based portals which expose the /api/3/action endpoints.
- For large AIS / GFW data, prefer BigQuery or GFW's official channels (see README output below).
"""

import os
import sys
import argparse
import requests
import shutil
import logging
from urllib.parse import urlparse

try:
    import geopandas as gpd
except Exception:
    gpd = None

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

CKAN_PORTALS = [
    {
        "name": "Vietnam Open Data (data.gov.vn)",
        "api": "https://data.gov.vn/api/3/action/package_search",
        "search_q": "fisheries OR fish OR aquaculture OR marine OR "
    },
    {
        "name": "OpenDevelopment Mekong (Vietnam hub)",
        "api": "https://opendevelopmentmekong.net/en/api/3/action/package_search",
        "search_q": "fisheries OR aquaculture OR marine OR mangrove"
    }
]

ALLOWED_RESOURCE_FORMATS = {"csv", "geojson", "shapefile", "zip", "gpkg", "geojsonl"}

HEADERS = {"User-Agent": "simon-data-lab-fetcher/1.0 (+https://www.simondatalab.de)"}


def safe_filename(url):
    p = urlparse(url)
    base = os.path.basename(p.path)
    if not base:
        base = p.netloc.replace('.', '_')
    return base


def download_url(url, dest_path):
    logging.info(f"Downloading {url} -> {dest_path}")
    try:
        with requests.get(url, stream=True, headers=HEADERS, timeout=60) as r:
            r.raise_for_status()
            with open(dest_path, 'wb') as f:
                shutil.copyfileobj(r.raw, f)
        return True
    except Exception as e:
        logging.warning(f"Failed to download {url}: {e}")
        return False


def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)


def download_ckan_portal(api_url, q, out_dir, rows=50):
    params = {"q": q, "rows": rows}
    logging.info(f"Querying CKAN API {api_url} q={q} rows={rows}")
    r = requests.get(api_url, params=params, headers=HEADERS, timeout=30)
    r.raise_for_status()
    data = r.json()
    if not data.get('success'):
        logging.warning(f"CKAN API returned success=false for {api_url}")
        return []
    results = data['result']['results']
    downloaded = []
    for pkg in results:
        pkg_id = pkg.get('id') or pkg.get('name')
        pkg_dir = os.path.join(out_dir, pkg_id)
        ensure_dir(pkg_dir)
        logging.info(f"Processing dataset: {pkg.get('title') or pkg_id}")
        for res in pkg.get('resources', []):
            res_format = (res.get('format') or '').lower()
            res_url = res.get('url') or res.get('url_type')
            if not res_url:
                continue
            if res_format in ALLOWED_RESOURCE_FORMATS or res_url.lower().endswith(tuple(['.csv', '.geojson', '.zip', '.shp', '.gpkg'])):
                fname = res.get('name') or safe_filename(res_url)
                dest = os.path.join(pkg_dir, fname)
                # normalize extension
                if not os.path.splitext(dest)[1]:
                    dest += os.path.splitext(safe_filename(res_url))[1] or '.dat'
                ok = download_url(res_url, dest)
                if ok:
                    downloaded.append(dest)
                    # attempt to convert shapefile/zip/gpkg to geojson if geopandas available
                    if gpd and dest.lower().endswith(('.zip', '.shp', '.gpkg')):
                        try:
                            logging.info(f"Attempting to read vector {dest} with geopandas")
                            gdf = gpd.read_file(dest)
                            gdf = gdf.to_crs(epsg=4326)
                            out_geojson = os.path.splitext(dest)[0] + '.geojson'
                            gdf.to_file(out_geojson, driver='GeoJSON')
                            logging.info(f"Wrote {out_geojson}")
                        except Exception as e:
                            logging.warning(f"Could not convert {dest} to GeoJSON: {e}")
            else:
                logging.debug(f"Skipping resource format {res_format} {res_url}")
    return downloaded


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', default='data/fishing', help='Output directory')
    parser.add_argument('--download', action='store_true', help='Actually download resources (network required)')
    parser.add_argument('--rows', type=int, default=50, help='Number of CKAN packages to fetch per portal')
    args = parser.parse_args(argv)

    ensure_dir(args.out)

    # Guidance notes for non-CKAN datasets
    guidance = {
        'global_fishing_watch': (
            'Global Fishing Watch data is large and requires free registration and acceptance of terms.\n'
            'Preferred access: BigQuery public dataset (gfw_research.filtered_* tables) or request via GFW data portal.\n'
            'See https://globalfishingwatch.org/data-download/ and GFW datasets & code pages for BigQuery examples.'
        ),
        'wdpa_protectedplanet': (
            'Protected Planet WDPA downloads often require registration and acceptance.\n'
            'Visit https://www.protectedplanet.net/ to request access and download shapefiles for MPAs.'
        )
    }

    logging.info('=== Guidance (non-CKAN datasets) ===')
    for k, v in guidance.items():
        logging.info(f"{k}: {v}")

    if not args.download:
        logging.info('No --download flag given; exiting after guidance. To fetch data run with --download')
        return

    # Download from CKAN portals
    all_downloads = []
    for portal in CKAN_PORTALS:
        try:
            dl = download_ckan_portal(portal['api'], portal['search_q'], args.out, rows=args.rows)
            all_downloads.extend(dl)
        except Exception as e:
            logging.error(f"Error querying {portal['name']}: {e}")

    logging.info('Download complete. Files saved under: %s' % args.out)
    if all_downloads:
        for f in all_downloads:
            logging.info(' - ' + f)
    else:
        logging.info('No files downloaded; check network or increase rows parameter.')


if __name__ == '__main__':
    main(sys.argv[1:])
