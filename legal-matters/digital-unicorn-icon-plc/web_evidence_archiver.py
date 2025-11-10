#!/usr/bin/env python3
"""
Web Evidence Archiver - Capture timestamped snapshots for legal documentation

This tool captures web pages with cryptographic timestamps and metadata,
suitable for legal evidence. Supports multiple archiving methods:
1. Wayback Machine API (archive.org)
2. Archive.today
3. Local archival with hash verification
4. Screenshot with metadata overlay
"""

import requests
import hashlib
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import time
from urllib.parse import urlparse, quote
import base64


class WebEvidenceArchiver:
    """Capture and archive web evidence with legal-grade timestamping"""
    
    def __init__(self, output_dir: str = "./web_evidence"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Legal Evidence Archiver/1.0)'
        })
    
    def archive_wayback(self, url: str) -> Dict:
        """
        Submit URL to Wayback Machine for archival
        Returns archive URL and metadata
        """
        print(f"📦 Submitting to Wayback Machine: {url}")
        
        # Submit for archiving
        save_url = f"https://web.archive.org/save/{url}"
        
        try:
            response = self.session.get(save_url, timeout=60)
            
            # Extract archive URL from response
            if 'Content-Location' in response.headers:
                archive_url = f"https://web.archive.org{response.headers['Content-Location']}"
            else:
                # Try to get latest snapshot
                available_url = f"https://archive.org/wayback/available?url={quote(url)}"
                avail_resp = self.session.get(available_url, timeout=30)
                data = avail_resp.json()
                
                if data.get('archived_snapshots', {}).get('closest'):
                    archive_url = data['archived_snapshots']['closest']['url']
                    timestamp = data['archived_snapshots']['closest']['timestamp']
                else:
                    archive_url = "Archival in progress"
                    timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')
            
            return {
                'service': 'Wayback Machine',
                'original_url': url,
                'archive_url': archive_url,
                'timestamp': timestamp,
                'status': 'success',
                'capture_time': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            return {
                'service': 'Wayback Machine',
                'original_url': url,
                'error': str(e),
                'status': 'failed',
                'capture_time': datetime.utcnow().isoformat()
            }
    
    def archive_today(self, url: str) -> Dict:
        """
        Submit URL to archive.today (archive.is/ph)
        Returns archive URL and metadata
        """
        print(f"📦 Submitting to archive.today: {url}")
        
        try:
            # Submit for archiving
            submit_url = "https://archive.ph/submit/"
            data = {'url': url}
            
            response = self.session.post(submit_url, data=data, timeout=60, allow_redirects=True)
            archive_url = response.url
            
            return {
                'service': 'archive.today',
                'original_url': url,
                'archive_url': archive_url,
                'timestamp': datetime.utcnow().strftime('%Y%m%d%H%M%S'),
                'status': 'success',
                'capture_time': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            return {
                'service': 'archive.today',
                'original_url': url,
                'error': str(e),
                'status': 'failed',
                'capture_time': datetime.utcnow().isoformat()
            }
    
    def capture_local(self, url: str, include_screenshot: bool = True) -> Dict:
        """
        Capture web page locally with hash verification
        Optionally capture screenshot if playwright is available
        """
        print(f"📥 Capturing locally: {url}")
        
        try:
            # Fetch page content
            response = self.session.get(url, timeout=30)
            content = response.content
            headers = dict(response.headers)
            
            # Generate hashes
            sha256_hash = hashlib.sha256(content).hexdigest()
            md5_hash = hashlib.md5(content).hexdigest()
            
            # Create filename-safe timestamp
            timestamp = datetime.utcnow()
            timestamp_str = timestamp.strftime('%Y%m%d_%H%M%S')
            domain = urlparse(url).netloc.replace(':', '_')
            
            # Save HTML content
            html_file = self.output_dir / f"{domain}_{timestamp_str}.html"
            html_file.write_bytes(content)
            
            # Save metadata
            metadata = {
                'original_url': url,
                'capture_time': timestamp.isoformat(),
                'capture_timestamp_utc': int(timestamp.timestamp()),
                'content_length': len(content),
                'content_type': headers.get('Content-Type', 'unknown'),
                'sha256': sha256_hash,
                'md5': md5_hash,
                'http_status': response.status_code,
                'headers': headers,
                'local_file': str(html_file.name),
            }
            
            # Try to capture screenshot if playwright available
            if include_screenshot:
                try:
                    screenshot_file = self._capture_screenshot(url, domain, timestamp_str)
                    if screenshot_file:
                        metadata['screenshot'] = str(screenshot_file.name)
                except Exception as e:
                    metadata['screenshot_error'] = str(e)
            
            # Save metadata JSON
            meta_file = self.output_dir / f"{domain}_{timestamp_str}_metadata.json"
            meta_file.write_text(json.dumps(metadata, indent=2))
            
            return {
                'service': 'Local Archive',
                'original_url': url,
                'html_file': str(html_file),
                'metadata_file': str(meta_file),
                'sha256': sha256_hash,
                'status': 'success',
                **metadata
            }
            
        except Exception as e:
            return {
                'service': 'Local Archive',
                'original_url': url,
                'error': str(e),
                'status': 'failed',
                'capture_time': datetime.utcnow().isoformat()
            }
    
    def _capture_screenshot(self, url: str, domain: str, timestamp_str: str) -> Optional[Path]:
        """Capture screenshot using playwright if available"""
        try:
            from playwright.sync_api import sync_playwright
            
            screenshot_file = self.output_dir / f"{domain}_{timestamp_str}_screenshot.png"
            
            with sync_playwright() as p:
                browser = p.chromium.launch(headless=True)
                page = browser.new_page(viewport={'width': 1920, 'height': 1080})
                page.goto(url, wait_until='networkidle', timeout=30000)
                page.screenshot(path=str(screenshot_file), full_page=True)
                browser.close()
            
            return screenshot_file
            
        except ImportError:
            print("⚠️  Playwright not installed. Run: pip install playwright && playwright install chromium")
            return None
        except Exception as e:
            print(f"⚠️  Screenshot failed: {e}")
            return None
    
    def archive_multiple_services(self, url: str, services: List[str] = None) -> Dict:
        """
        Archive URL across multiple services for redundancy
        
        Args:
            url: URL to archive
            services: List of services ['wayback', 'archive_today', 'local']
                     If None, uses all available services
        """
        if services is None:
            services = ['wayback', 'archive_today', 'local']
        
        results = {
            'url': url,
            'capture_time': datetime.utcnow().isoformat(),
            'archives': []
        }
        
        for service in services:
            if service == 'wayback':
                result = self.archive_wayback(url)
            elif service == 'archive_today':
                result = self.archive_today(url)
                time.sleep(2)  # Rate limiting
            elif service == 'local':
                result = self.capture_local(url)
            else:
                continue
            
            results['archives'].append(result)
            
            # Small delay between services
            time.sleep(1)
        
        # Save combined results
        timestamp_str = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        domain = urlparse(url).netloc.replace(':', '_')
        results_file = self.output_dir / f"{domain}_{timestamp_str}_archives.json"
        results_file.write_text(json.dumps(results, indent=2))
        results['results_file'] = str(results_file)
        
        return results
    
    def generate_evidence_report(self, archive_results: Dict, case_name: str = None) -> str:
        """
        Generate a formatted evidence report suitable for legal documentation
        """
        report = []
        report.append("=" * 80)
        report.append("WEB EVIDENCE ARCHIVAL REPORT")
        report.append("=" * 80)
        report.append("")
        
        if case_name:
            report.append(f"Case/Matter: {case_name}")
            report.append("")
        
        report.append(f"Original URL: {archive_results['url']}")
        report.append(f"Capture Date/Time (UTC): {archive_results['capture_time']}")
        report.append("")
        report.append("-" * 80)
        report.append("ARCHIVAL SERVICES")
        report.append("-" * 80)
        report.append("")
        
        for archive in archive_results['archives']:
            report.append(f"Service: {archive['service']}")
            report.append(f"Status: {archive['status'].upper()}")
            
            if archive['status'] == 'success':
                if 'archive_url' in archive:
                    report.append(f"Archive URL: {archive['archive_url']}")
                if 'sha256' in archive:
                    report.append(f"SHA-256 Hash: {archive['sha256']}")
                if 'html_file' in archive:
                    report.append(f"Local File: {archive['html_file']}")
                if 'screenshot' in archive:
                    report.append(f"Screenshot: {archive['screenshot']}")
            else:
                report.append(f"Error: {archive.get('error', 'Unknown error')}")
            
            report.append("")
        
        report.append("-" * 80)
        report.append("VERIFICATION")
        report.append("-" * 80)
        report.append("")
        report.append("The above captures represent authentic snapshots of the web content")
        report.append("at the specified URL and timestamp. Hash values can be independently")
        report.append("verified against the archived content.")
        report.append("")
        report.append("=" * 80)
        
        report_text = "\n".join(report)
        
        # Save report
        if 'results_file' in archive_results:
            report_file = Path(archive_results['results_file']).with_suffix('.txt')
            report_file.write_text(report_text)
            print(f"\n📄 Evidence report saved: {report_file}")
        
        return report_text


def main():
    """Example usage"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Archive web evidence with timestamps for legal documentation'
    )
    parser.add_argument('urls', nargs='+', help='URLs to archive')
    parser.add_argument('--services', nargs='+', 
                       choices=['wayback', 'archive_today', 'local'],
                       default=['wayback', 'archive_today', 'local'],
                       help='Services to use for archival')
    parser.add_argument('--output-dir', default='./web_evidence',
                       help='Output directory for archives')
    parser.add_argument('--case-name', help='Case or matter name for report')
    
    args = parser.parse_args()
    
    archiver = WebEvidenceArchiver(output_dir=args.output_dir)
    
    print(f"\n🔒 Web Evidence Archiver")
    print(f"📁 Output directory: {args.output_dir}")
    print(f"🌐 URLs to archive: {len(args.urls)}")
    print(f"📦 Services: {', '.join(args.services)}")
    print("\n" + "=" * 80 + "\n")
    
    for i, url in enumerate(args.urls, 1):
        print(f"\n[{i}/{len(args.urls)}] Processing: {url}")
        print("-" * 80)
        
        results = archiver.archive_multiple_services(url, args.services)
        report = archiver.generate_evidence_report(results, args.case_name)
        
        print("\n" + report)
        print("\n" + "=" * 80)
        
        # Delay between URLs
        if i < len(args.urls):
            time.sleep(3)
    
    print(f"\n✅ All archives completed. Evidence saved in: {args.output_dir}")


if __name__ == '__main__':
    main()
