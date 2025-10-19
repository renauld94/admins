# Business Card - Print Ready Files

## � PDF DISPLAY FIXED - Use These Files

### ✅ WORKING Solutions (Choose One):

**Option 1: Simple HTML (BEST for home printers)**

1. **Open `business-card-simple.html` in any web browser**
2. **Press Ctrl+P (Windows) or Cmd+P (Mac)**
3. **Enable "Background graphics" in print settings**
4. **Print on cardstock paper**

**Option 2: Generated PDF (BEST for print shops)**

1. **Use `business-card-complete.pdf`** - Generated from HTML
2. **Send directly to printer or print shop**

**Option 3: SVG Version (BEST compatibility)**

1. **Open `business-card-svg.html`** - Works with any printer
2. **Print with any browser - no special settings needed**

Looking at these browser console logs from your Jellyfin instance, I can identify several issues:

Key Problems
500 Internal Server Errors on Primary Images: Multiple failed requests to load channel thumbnails/primary images with the tag 543b6ca4c9f21c87d81daf7a932499c0

PlaybackInfo Endpoint Failure:

JavaScript ScrollTo Error:

Recommended Actions
Let me check your Jellyfin server logs to diagnose the root cause:

Read Learning-Management-System-Academy


ssh -p 2222 root@136.243.155.166 "ssh simonadmin@10.0.0.103 'docker logs --tail 100 jellyfin-simonadmin 2>&1 | grep -i \"error\|exception\|fail\"'"
Auto approved by rules ssh, grep, exception, fail


ssh -p 2222 root@136.243.155.166 "ssh simonadmin@10.0.0.103 'docker logs --tail 200 jellyfin-simonadmin 2>&1 | grep -E \"(Primary|PlaybackInfo|Image|500)\"'"
Auto approve rules PlaybackInfo, Image, 500)\"'" added

Diagnosis
Based on the console logs and server logs, the issues are:

Root Cause: Network Connectivity Issues
The Jellyfin server is experiencing network connectivity problems reaching raw.githubusercontent.com:443 to fetch EPG (Electronic Program Guide) metadata and channel images.

This causes:

500 errors on Primary images - Can't download/cache channel logos
PlaybackInfo failures - Can't fetch complete channel metadata needed for playback
Missing EPG data - Guide information ./scripts/fix_jellyfin_livetv_errors.sh
### Alternative: PDF Files

- `neurodata_front_standard.pdf` - Front of business card
- `neurodata_back_standard.pdf` - Back of business card
- Both files are exactly 3.5" × 2" (89mm × 51mm)

### Double-Sided Printing

1. Print front first
2. Flip paper (ask printer manual for correct orientation)
3. Print back on reverse side

### QR Code

- `qr-code-print-300dpi.png` - High-resolution QR code (300 DPI)
- Links to: https://www.simondatalab.de
- QR code is already embedded in the HTML and PDF files

## 🖨️ Printer Settings

**Paper:** Cardstock (200-300gsm) for professional feel
**Size:** 3.5" × 2" (89mm × 51mm) - Standard business card size
**Quality:** Best/High quality for crisp text and gradients
**Color:** Full color (gradients and brand colors)

## ✂️ Finishing

After printing, cut to exact size using:

- Paper cutter for straight edges
- Corner rounder (optional) for rounded corners
- Business card cutter if available

## 💡 Tips

- Test print on regular paper first to check alignment
- If colors look dull, enable "High Quality" or "Photo" mode
- For bulk printing, consider a local print shop
- Keep PDF files as backup - they work with any printer software

---

**Brand:** Neuro DataLab  
**Contact:** contact@simondatalab.de  
**Website:** www.simondatalab.de