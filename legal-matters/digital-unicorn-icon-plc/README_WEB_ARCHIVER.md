# Web Evidence Archiver for Legal Documentation

This tool captures timestamped snapshots of web pages suitable for legal evidence, similar to web.archive.org but with multiple redundant services and local verification.

## Features

✅ **Multiple Archive Services**
- Wayback Machine (archive.org) - Official Internet Archive
- archive.today (archive.ph) - Alternative archival service
- Local archival with cryptographic hashes

✅ **Legal-Grade Evidence**
- UTC timestamps
- SHA-256 and MD5 hash verification
- HTTP headers preserved
- Full metadata capture
- Screenshot support (optional)

✅ **Evidence Reports**
- Formatted reports suitable for legal submissions
- All archive URLs and timestamps
- Verification hashes
- JSON metadata for programmatic access

## Installation

```bash
# Basic installation
cd /home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc

# Install dependencies
pip install requests

# Optional: For screenshots
pip install playwright
playwright install chromium
```

## Usage

### Basic Usage - Archive a Single URL

```bash
python web_evidence_archiver.py "https://example.com/evidence-page"
```

### Archive Multiple URLs

```bash
python web_evidence_archiver.py \
  "https://example.com/page1" \
  "https://example.com/page2" \
  "https://example.com/page3"
```

### With Case Name for Documentation

```bash
python web_evidence_archiver.py \
  --case-name "Digital Unicorn vs ICON PLC - Intellectual Property Claim" \
  "https://example.com/evidence-page"
```

### Specific Services Only

```bash
# Wayback Machine only
python web_evidence_archiver.py --services wayback "https://example.com"

# Local archive only (no external services)
python web_evidence_archiver.py --services local "https://example.com"

# Wayback + Local (skip archive.today)
python web_evidence_archiver.py --services wayback local "https://example.com"
```

### Custom Output Directory

```bash
python web_evidence_archiver.py \
  --output-dir "./evidence/2025-11-05" \
  "https://example.com"
```

## Python API Usage

```python
from web_evidence_archiver import WebEvidenceArchiver

# Initialize
archiver = WebEvidenceArchiver(output_dir="./my_evidence")

# Archive to all services
results = archiver.archive_multiple_services("https://example.com")

# Generate evidence report
report = archiver.generate_evidence_report(
    results, 
    case_name="My Legal Matter"
)
print(report)

# Individual services
wayback_result = archiver.archive_wayback("https://example.com")
local_result = archiver.capture_local("https://example.com")
```

## Output Files

For each URL archived, you'll get:

```
web_evidence/
├── example.com_20251105_143022.html              # Original HTML
├── example.com_20251105_143022_metadata.json     # Full metadata with hashes
├── example.com_20251105_143022_screenshot.png    # Screenshot (if available)
├── example.com_20251105_143022_archives.json     # All archive results
└── example.com_20251105_143022_archives.txt      # Evidence report
```

## Evidence Report Example

```
================================================================================
WEB EVIDENCE ARCHIVAL REPORT
================================================================================

Case/Matter: Digital Unicorn vs ICON PLC - Intellectual Property Claim

Original URL: https://example.com/evidence
Capture Date/Time (UTC): 2025-11-05T14:30:22.123456

--------------------------------------------------------------------------------
ARCHIVAL SERVICES
--------------------------------------------------------------------------------

Service: Wayback Machine
Status: SUCCESS
Archive URL: https://web.archive.org/web/20251105143022/https://example.com/evidence

Service: archive.today
Status: SUCCESS
Archive URL: https://archive.ph/AbCdE

Service: Local Archive
Status: SUCCESS
SHA-256 Hash: abc123def456...
Local File: example.com_20251105_143022.html
Screenshot: example.com_20251105_143022_screenshot.png

--------------------------------------------------------------------------------
VERIFICATION
--------------------------------------------------------------------------------

The above captures represent authentic snapshots of the web content
at the specified URL and timestamp. Hash values can be independently
verified against the archived content.
================================================================================
```

## Why This is Better Than Simple Screenshots

1. **Third-Party Verification**: Wayback Machine and archive.today are independent services that timestamp content
2. **Cryptographic Hashes**: SHA-256 proves content hasn't been tampered with
3. **Metadata Preservation**: HTTP headers, content type, timestamps all captured
4. **Multiple Redundancy**: If one service fails, others provide backup
5. **Verifiable by Court**: Archive.org URLs are widely accepted as evidence
6. **Automatic Timestamps**: UTC timestamps from independent services
7. **Full Page Content**: Not just visual, but complete HTML and metadata

## Legal Considerations

- **Wayback Machine**: Widely accepted in courts worldwide
- **archive.today**: Additional independent verification
- **Cryptographic Hashes**: Proves authenticity of captured content
- **UTC Timestamps**: Universal time standard for legal documentation
- **HTTP Headers**: Prove the content source and transmission details

## For Your Digital Unicorn Case

Example usage for your case:

```bash
python web_evidence_archiver.py \
  --case-name "Digital Unicorn ICON PLC - Course Plagiarism Evidence" \
  --output-dir "./digital_unicorn_evidence" \
  "http://136.243.155.166:8086/course/view.php?id=2" \
  "https://linked-in-profile-url" \
  "https://any-other-evidence-urls"
```

This will create timestamped, hash-verified archives suitable for legal submission.

## Troubleshooting

### Archive Services Rate Limiting
If you get rate limited, add delays:
```bash
python web_evidence_archiver.py url1 && sleep 10 && \
python web_evidence_archiver.py url2 && sleep 10 && \
python web_evidence_archiver.py url3
```

### Screenshot Not Working
Screenshots require Playwright:
```bash
pip install playwright
playwright install chromium
```

### Connection Errors
If archiving fails, at least the local archive will succeed, giving you hash-verified evidence.

## Additional Resources

- [Wayback Machine API](https://archive.org/help/wayback_api.php)
- [archive.today](https://archive.ph/)
- [Legal precedents for web archives](https://en.wikipedia.org/wiki/Internet_Archive#Legal_cases)
