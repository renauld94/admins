#!/usr/bin/env python3
"""Fetch WMS GetCapabilities via the local proxy and print layer names.
Usage: python get_wms_layers.py --proxy http://127.0.0.1:8001 --service /wms
"""
import requests
import xml.etree.ElementTree as ET
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--proxy', default='http://127.0.0.1:8001')
parser.add_argument('--service', default='/wms')
args = parser.parse_args()

url = args.proxy.rstrip('/') + args.service + '?SERVICE=WMS&REQUEST=GetCapabilities'
print('Requesting', url)
try:
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    xml = ET.fromstring(r.content)
    layers = xml.findall('.//{http://www.opengis.net/wms}Layer/{http://www.opengis.net/wms}Name')
    if not layers:
        # Try without namespace
        layers = xml.findall('.//Layer/Name')
    print('Found layers:')
    for l in layers:
        print(' -', l.text)
except Exception as e:
    print('Error fetching/parsing:', e)
    resp = locals().get('r')
    if resp is not None:
        print('Response status:', getattr(resp, 'status_code', None))
        print('Response length:', len(getattr(resp, 'content', b'')))
    else:
        print('No response object available')
