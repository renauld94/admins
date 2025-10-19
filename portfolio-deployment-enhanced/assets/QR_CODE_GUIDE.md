# QR Code Generation Guide

## 🎯 Quick Start - 3 Methods

### Method 1: Python Script (Recommended)
**Best for:** Custom styling, batch generation, automation

```bash
# Install dependencies
pip install qrcode[pil] pillow

# Run generator
cd /home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced/assets
python3 generate_qr_code.py

# Output: 4 QR code variations in assets/ folder
```

### Method 2: Online Generator (Fastest)
**Best for:** Quick one-off generation

1. **Visit:** [qr-code-generator.com](https://www.qr-code-generator.com/)
2. **Enter URL:** `https://www.simondatalab.de`
3. **Customize:**
   - Size: 1000×1000px minimum
   - Format: PNG
   - Error correction: High (30%)
   - Colors: Match brand (#0ea5e9 or #0f172a)
4. **Download** and save as `qr-code.png`

**Alternative Sites:**
- [qr.io](https://qr.io/) - Advanced analytics
- [goqr.me](https://goqr.me/) - Simple, free
- [qrcode-monkey.com](https://www.qrcode-monkey.com/) - Logo embedding

### Method 3: Command Line (Linux/Mac)
**Best for:** Quick terminal generation

```bash
# Install qrencode
sudo apt install qrencode  # Ubuntu/Debian
# or
brew install qrencode      # macOS

# Generate QR code
qrencode -o qr-code.png -s 20 -l H "https://www.simondatalab.de"

# Options:
#   -s 20  : Size (pixels per module)
#   -l H   : Error correction High
#   -o     : Output file
```

---

## 📐 QR Code Specifications

### Size Requirements

| Use Case | Minimum Size | Recommended | DPI |
|----------|--------------|-------------|-----|
| Business Card | 400×400px | 600×600px | 300 |
| Website | 200×200px | 400×400px | 72 |
| Print Materials | 800×800px | 1200×1200px | 300 |
| Presentation | 600×600px | 1000×1000px | 150 |

### Brand Colors for QR Codes

```css
/* Recommended color combinations */

/* Option 1: Classic (Best readability) */
Foreground: #0f172a (Dark Navy)
Background: #ffffff (White)

/* Option 2: Branded */
Foreground: #0ea5e9 (Sky Blue)
Background: #ffffff (White)

/* Option 3: Minimal */
Foreground: #000000 (Black)
Background: #ffffff (White)
```

### Error Correction Levels

| Level | Recovery | Best For |
|-------|----------|----------|
| L (Low) | 7% | Digital display, clean environments |
| M (Medium) | 15% | General purpose |
| Q (Quartile) | 25% | Moderate damage expected |
| **H (High)** | 30% | **Business cards, print (recommended)** |

**Use High (H)** for business cards - allows logo overlay and handles print quality variations.

---

## 🎨 Adding QR Code to Business Card

### Step 1: Generate QR Code

Choose any method above. Save as: `qr-code.png`

### Step 2: Update HTML

**Option A: Direct Image (Simple)**

```html
<!-- Replace the QR placeholder in business-card.html -->
<div class="qr-section">
    <img src="qr-code.png" 
         alt="Scan for portfolio" 
         class="qr-code"
         width="140" 
         height="140">
    <div class="qr-label">Scan for portfolio</div>
</div>
```

**Option B: Inline SVG (Advanced)**

```html
<!-- For vector QR code -->
<div class="qr-section">
    <svg class="qr-code" width="140" height="140" viewBox="0 0 100 100">
        <!-- QR code SVG data here -->
    </svg>
    <div class="qr-label">Scan for portfolio</div>
</div>
```

### Step 3: Add CSS Styling

```css
.qr-code {
    width: 140px;
    height: 140px;
    background: #ffffff;
    border-radius: 12px;
    padding: 10px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    border: 2px solid rgba(14, 165, 233, 0.2);
}

.qr-code:hover {
    transform: scale(1.05);
    box-shadow: 0 6px 20px rgba(14, 165, 233, 0.4);
    transition: all 0.3s ease;
}
```

### Step 4: Test & Deploy

```bash
# 1. Test QR code with your phone
#    - Open camera app
#    - Point at QR code
#    - Verify it opens https://www.simondatalab.de

# 2. Deploy to production
cd /home/simon/Learning-Management-System-Academy
./scripts/deploy_improved_portfolio.sh

# 3. Verify online
# Open: https://www.simondatalab.de/assets/business-card.html
```

---

## 🖨️ Print Preparation

### For Professional Printing

1. **Generate at 300 DPI minimum**
   ```bash
   python3 generate_qr_code.py
   # Use: qr-code-print-300dpi.png
   ```

2. **Test before printing**
   - Print one test card
   - Scan with multiple phones
   - Verify readability

3. **Size on business card**
   - Minimum: 0.5" × 0.5" (1.27cm)
   - Recommended: 0.75" × 0.75" (1.9cm)
   - Maximum: 1" × 1" (2.54cm)

4. **Placement**
   - Bottom right corner (standard)
   - Top right corner (alternative)
   - Back of card (for minimal front)

### Testing Checklist

- [ ] Scans successfully with iPhone camera
- [ ] Scans successfully with Android camera
- [ ] Opens correct URL (https://www.simondatalab.de)
- [ ] Clear and crisp on print preview
- [ ] High contrast (dark on white)
- [ ] Proper error correction level (H)
- [ ] No distortion or blurring

---

## 🚀 Advanced: QR Code with Logo

### Python Method

```python
from PIL import Image
import qrcode

# Generate QR
qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_H)
qr.add_data('https://www.simondatalab.de')
qr.make(fit=True)

img = qr.make_image(fill_color="#0f172a", back_color="white").convert('RGB')

# Add logo
logo = Image.open('logo-icon.png')
logo_size = img.size[0] // 5
logo = logo.resize((logo_size, logo_size))

# Calculate center position
pos = ((img.size[0] - logo_size) // 2, (img.size[1] - logo_size) // 2)
img.paste(logo, pos)

img.save('qr-with-logo.png', dpi=(300, 300))
```

### Online Method

1. Visit [qrcode-monkey.com](https://www.qrcode-monkey.com/)
2. Enter URL: `https://www.simondatalab.de`
3. Click "Add Logo Image"
4. Upload: `logo-icon.svg` or `logo-primary.svg`
5. Adjust logo size: 20-25% of QR code
6. Download high-res PNG

---

## 📊 Analytics & Tracking (Optional)

### URL Shortener with Analytics

```bash
# Use bit.ly or similar for tracking
Original: https://www.simondatalab.de
Shortened: https://bit.ly/simon-datalab

# Benefits:
- Track scan count
- Geographic data
- Device types
- Referral sources
```

### UTM Parameters

```bash
# Add tracking to URL
https://www.simondatalab.de?utm_source=business_card&utm_medium=qr_code&utm_campaign=networking_2025

# Then check in Google Analytics
```

---

## 🔧 Troubleshooting

### QR Code Won't Scan

**Problem:** Phone camera doesn't recognize QR code

**Solutions:**
1. Increase error correction to High (H)
2. Increase size (minimum 0.75" on card)
3. Ensure high contrast (dark on white)
4. Remove logo if present
5. Test with multiple phones
6. Verify URL is correct

### Blurry in Print

**Problem:** QR code looks blurry when printed

**Solutions:**
1. Generate at 300 DPI minimum
2. Use PNG, not JPG
3. Don't scale/resize in design software
4. Export at exact size needed
5. Use vector SVG if possible

### Wrong URL Opens

**Problem:** QR code opens wrong website

**Solutions:**
1. Verify URL in generator: `https://www.simondatalab.de`
2. Test before printing
3. Regenerate if incorrect
4. Check for typos

---

## 📦 Quick Command Reference

```bash
# Install Python dependencies
pip install qrcode[pil] pillow

# Generate QR codes
cd portfolio-deployment-enhanced/assets
python3 generate_qr_code.py

# Deploy to production
cd /home/simon/Learning-Management-System-Academy
./scripts/deploy_improved_portfolio.sh

# Test URLs
curl -I https://www.simondatalab.de
curl -I https://www.simondatalab.de/assets/business-card.html
```

---

## ✅ Final Checklist

Before ordering business cards:

- [ ] QR code generated at 300 DPI
- [ ] Tested with iPhone and Android
- [ ] Opens https://www.simondatalab.de
- [ ] Added to business-card.html
- [ ] Styled with brand colors
- [ ] Print preview looks clear
- [ ] Deployed to production
- [ ] Test card printed and verified
- [ ] Ready for full order

---

**Need Help?**
- Email: simon@simondatalab.de
- Test your QR code generator script: `python3 generate_qr_code.py`
