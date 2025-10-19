# Simon Renauld - Brand Assets

Professional business card and logo suite for data engineering and analytics branding.

## 📁 Files

### Business Card
- **`business-card.html`** - Interactive, print-ready business card template
  - Standard size: 3.5" × 2" (89mm × 51mm)
  - 300 DPI print-ready
  - Includes QR code placeholder
  - Professional gradient design

### Logo Suite
- **`logo-suite.html`** - Interactive logo showcase and download page
- **`logo-primary.svg`** - Primary logo (200×200px)
- **`logo-horizontal.svg`** - Horizontal logo with wordmark (400×100px)
- **`logo-icon.svg`** - Icon/favicon version (64×64px)

## 🎨 Brand Colors

```css
Primary:   #0ea5e9  /* Sky Blue */
Secondary: #8b5cf6  /* Purple */
Accent:    #06b6d4  /* Cyan */
Dark:      #0f172a  /* Navy */
Light:     #ffffff  /* White */
```

## 📋 Business Card - Quick Start

### Print Instructions
1. Open `business-card.html` in your browser
2. Press `Ctrl/Cmd + P` to open print dialog
3. Select "Save as PDF" or print directly
4. Settings:
   - Margins: None
   - Background graphics: Enabled
   - Scale: 100%

### Add QR Code
1. Visit [qr-code-generator.com](https://www.qr-code-generator.com)
2. Enter URL: `https://www.simondatalab.de`
3. Download as PNG (300 DPI, 1000px)
4. Replace QR placeholder in HTML or paste into PDF editor

### Professional Printing
- **Recommended Services:** VistaPrint, Moo, GotPrint
- **Paper Stock:** 16pt cardstock
- **Finish:** Matte or silk finish
- **Quantity:** Minimum 100 cards for best pricing
- **Bleed:** Add 0.125" if required by printer

## 🖼️ Logo Usage Guide

### File Formats
- **SVG:** Use for web, scalable graphics
- **PNG:** Export from SVG at 2x, 3x for retina displays
- **ICO:** For favicons (use online converter)

### Sizing Guidelines
| Use Case | Logo Type | Minimum Size |
|----------|-----------|--------------|
| Website favicon | Icon | 32×32px |
| App icon | Icon | 256×256px |
| Email signature | Horizontal | 200px width |
| Social media avatar | Primary/Icon | 400×400px |
| Website header | Horizontal | 300px width |
| Print materials | Primary/Horizontal | 300 DPI |

### Export Instructions

#### High-Resolution PNG Export
```bash
# Using Inkscape (command line)
inkscape logo-primary.svg --export-png=logo-primary.png --export-width=1000 --export-height=1000

# Or use online tools:
# - cloudconvert.com
# - ezgif.com
```

#### Create Favicon
1. Export `logo-icon.svg` as 256×256px PNG
2. Visit [favicon.io](https://favicon.io/favicon-converter/)
3. Upload PNG and download ICO package
4. Place in website root as `favicon.ico`

#### Social Media Sizes
- **LinkedIn:** 400×400px (primary or icon)
- **Twitter:** 400×400px (primary or icon)
- **Facebook:** 180×180px (icon)
- **GitHub:** 400×400px (primary or icon)

### Do's and Don'ts

✅ **DO:**
- Use on clean, contrasting backgrounds
- Maintain minimum clear space (equal to one node height)
- Use provided color variations for different backgrounds
- Scale proportionally

❌ **DON'T:**
- Distort or stretch the logo
- Change brand colors
- Add drop shadows or effects
- Rotate the logo
- Place on busy/patterned backgrounds
- Scale below minimum sizes

## 🌐 Web Integration

### HTML Favicon
```html
<!-- Add to <head> section -->
<link rel="icon" type="image/svg+xml" href="assets/logo-icon.svg">
<link rel="alternate icon" href="assets/favicon.ico">
<link rel="apple-touch-icon" href="assets/logo-icon-180.png">
```

### Email Signature
```html
<img src="https://www.simondatalab.de/assets/logo-horizontal.svg" 
     alt="Simon Renauld - Data Intelligence" 
     width="200" 
     style="display:block;border:0;">
```

### Social Media Meta Tags
```html
<!-- Open Graph -->
<meta property="og:image" content="https://www.simondatalab.de/assets/logo-primary.png">
<meta property="og:image:width" content="1000">
<meta property="og:image:height" content="1000">

<!-- Twitter -->
<meta name="twitter:image" content="https://www.simondatalab.de/assets/logo-primary.png">
<meta name="twitter:card" content="summary">
```

## 📦 Package Contents

```
assets/
├── business-card.html          # Interactive business card template
├── logo-suite.html             # Logo showcase page
├── logo-primary.svg            # Primary logo (200×200)
├── logo-horizontal.svg         # Horizontal with text (400×100)
├── logo-icon.svg              # Icon/favicon (64×64)
└── README.md                  # This file
```

## 🚀 Quick Deploy

To add these assets to your portfolio:

```bash
# 1. Assets are already in portfolio-deployment-enhanced/assets/
# 2. Deploy to production
cd /home/simon/Learning-Management-System-Academy
./scripts/deploy_improved_portfolio.sh

# 3. Access online
# Business card: https://www.simondatalab.de/assets/business-card.html
# Logo suite: https://www.simondatalab.de/assets/logo-suite.html
```

## 🎓 Design Concept

The logo represents **enterprise data intelligence** through:
- **Hexagon Frame:** Structured, systematic approach to data engineering
- **Neural Network:** AI/ML capabilities and intelligent systems
- **Connected Nodes:** Data flow, integration, and unified platforms
- **Gradient Colors:** Technology, innovation, and modern analytics

The design conveys:
- **Technical Expertise:** Neural network symbolizes ML/AI knowledge
- **Data Integration:** Connected nodes show unified data platforms
- **Enterprise Scale:** Structured hexagon represents systematic architecture
- **Innovation:** Modern gradient colors signal cutting-edge solutions

## 📞 Support

For questions about brand assets:
- **Email:** simon@simondatalab.de
- **Website:** https://www.simondatalab.de

---

**Version:** 1.0  
**Last Updated:** October 17, 2025  
**Copyright:** © 2025 Simon Renauld. All rights reserved.
