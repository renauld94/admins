#!/usr/bin/env python3
"""Import all Grafana dashboard JSON files in this folder to a Grafana instance.

This is a small wrapper around the repo's `import_grafana_dashboards.py` script.

Usage:
  python3 import_all_grafana.py --grafana-url http://localhost:3000 --api-token <TOKEN>

It iterates JSON files matching `grafana*.json` in the current directory.
"""
import os
import argparse
import subprocess
import glob


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--grafana-url', required=True)
    p.add_argument('--api-token', required=True)
    p.add_argument('--folder', default=os.path.dirname(__file__))
    args = p.parse_args()

    pattern = os.path.join(args.folder, 'grafana*.json')
    files = sorted(glob.glob(pattern))
    if not files:
        print('No grafana JSON dashboards found in', args.folder)
        return

    script = os.path.join(args.folder, 'import_grafana_dashboards.py')
    # the repo has import_grafana_dashboards.py; if not present, print the filenames only
    if not os.path.exists(script):
        print('Wrapper: found dashboards but import script not found. Files:')
        for f in files:
            print('  ', f)
        return

    for f in files:
        print('Importing', os.path.basename(f))
        cmd = [
            'python3', script,
            '--grafana-url', args.grafana_url,
            '--api-token', args.api_token,
            f
        ]
        print('  Running:', ' '.join(cmd))
        try:
            subprocess.check_call(cmd)
        except subprocess.CalledProcessError as e:
            print('  Import failed for', f, '->', e)


if __name__ == '__main__':
    main()
