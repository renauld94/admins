#!/usr/bin/env python3
"""
QR Code Generator for Simon Renauld Business Card
Generates a high-quality QR code linking to portfolio website
"""

import sys

try:
    import qrcode
    from qrcode.image.styledpil import StyledPilImage
    from qrcode.image.styles.moduledrawers import RoundedModuleDrawer, SquareModuleDrawer
    from qrcode.image.styles.colormasks import SolidFillColorMask
    from PIL import Image
except ImportError:
    print("ERROR: Required packages not installed")
    print("\nInstall with:")
    print("  pip install qrcode[pil] pillow")
    sys.exit(1)


def generate_qr_basic(url, output_path):
    """Generate a basic high-quality QR code"""
    qr = qrcode.QRCode(
        version=1,  # Auto-size
        error_correction=qrcode.constants.ERROR_CORRECT_H,  # Highest error correction
        box_size=20,  # Size of each box in pixels
        border=2,  # Minimum border size
    )
    
    qr.add_data(url)
    qr.make(fit=True)
    
    # Create image with custom colors matching brand
    img = qr.make_image(
        fill_color="#0f172a",  # Dark blue (brand color)
        back_color="white"
    )
    
    img.save(output_path)
    print(f"✅ Basic QR code saved: {output_path}")
    return output_path


def generate_qr_styled(url, output_path):
    """Generate a styled QR code with rounded corners"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=20,
        border=2,
    )
    
    qr.add_data(url)
    qr.make(fit=True)
    
    # Create styled image with rounded modules
    img = qr.make_image(
        image_factory=StyledPilImage,
        module_drawer=RoundedModuleDrawer(),  # Rounded corners for modern look
        color_mask=SolidFillColorMask(
            back_color=(255, 255, 255),  # White background
            front_color=(15, 23, 42)     # Brand dark blue
        )
    )
    
    img.save(output_path)
    print(f"✅ Styled QR code saved: {output_path}")
    return output_path


def generate_qr_gradient(url, output_path):
    """Generate QR code with gradient colors"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=20,
        border=2,
    )
    
    qr.add_data(url)
    qr.make(fit=True)
    
    # Create with primary brand color
    img = qr.make_image(
        fill_color="#0ea5e9",  # Sky blue (primary brand color)
        back_color="white"
    )
    
    img.save(output_path)
    print(f"✅ Gradient-colored QR code saved: {output_path}")
    return output_path


def generate_qr_with_logo(url, logo_path, output_path):
    """Generate QR code with centered logo"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,  # High correction allows logo overlay
        box_size=20,
        border=2,
    )
    
    qr.add_data(url)
    qr.make(fit=True)
    
    # Generate QR code
    img = qr.make_image(
        fill_color="#0f172a",
        back_color="white"
    ).convert('RGB')
    
    # Add logo in center
    try:
        logo = Image.open(logo_path)
        
        # Calculate logo size (should be about 1/5 of QR code size)
        qr_width, qr_height = img.size
        logo_size = min(qr_width, qr_height) // 5
        
        # Resize logo
        logo = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        
        # Calculate position to center logo
        logo_pos = ((qr_width - logo_size) // 2, (qr_height - logo_size) // 2)
        
        # Paste logo
        img.paste(logo, logo_pos, logo if logo.mode == 'RGBA' else None)
        
        img.save(output_path)
        print(f"✅ QR code with logo saved: {output_path}")
        return output_path
        
    except FileNotFoundError:
        print(f"⚠️  Logo file not found: {logo_path}")
        print("   Generating QR code without logo...")
        img.save(output_path)
        return output_path


def main():
    # Configuration
    PORTFOLIO_URL = "https://www.simondatalab.de"
    OUTPUT_DIR = "/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced/assets"
    LOGO_PATH = f"{OUTPUT_DIR}/logo-icon.svg"
    
    print("=" * 60)
    print("🎨 QR Code Generator - Simon Renauld Portfolio")
    print("=" * 60)
    print(f"Target URL: {PORTFOLIO_URL}")
    print(f"Output Directory: {OUTPUT_DIR}")
    print()
    
    # Generate multiple versions
    print("Generating QR codes...")
    print()
    
    # 1. Basic high-quality QR
    generate_qr_basic(
        PORTFOLIO_URL,
        f"{OUTPUT_DIR}/qr-code-basic.png"
    )
    
    # 2. Styled with rounded corners
    try:
        generate_qr_styled(
            PORTFOLIO_URL,
            f"{OUTPUT_DIR}/qr-code-styled.png"
        )
    except Exception as e:
        print(f"⚠️  Styled QR generation failed: {e}")
    
    # 3. Brand colored
    generate_qr_gradient(
        PORTFOLIO_URL,
        f"{OUTPUT_DIR}/qr-code-brand.png"
    )
    
    # 4. Print-optimized (300 DPI)
    qr_print = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=40,  # Larger for print
        border=4,
    )
    qr_print.add_data(PORTFOLIO_URL)
    qr_print.make(fit=True)
    img_print = qr_print.make_image(fill_color="#0f172a", back_color="white")
    print_path = f"{OUTPUT_DIR}/qr-code-print-300dpi.png"
    img_print.save(print_path, dpi=(300, 300))
    print(f"✅ Print-quality QR code (300 DPI) saved: {print_path}")
    
    print()
    print("=" * 60)
    print("✨ QR Code Generation Complete!")
    print("=" * 60)
    print()
    print("Files generated:")
    print(f"  • qr-code-basic.png         - Standard QR code")
    print(f"  • qr-code-styled.png        - Rounded corners")
    print(f"  • qr-code-brand.png         - Brand colored")
    print(f"  • qr-code-print-300dpi.png  - Print ready (300 DPI)")
    print()
    print("📋 Next Steps:")
    print("  1. Review generated QR codes")
    print("  2. Test with phone camera")
    print("  3. Add to business card HTML")
    print("  4. Deploy to production")
    print()
    print("🔗 Test your QR code:")
    print(f"   Scan with phone camera → Should open {PORTFOLIO_URL}")


if __name__ == "__main__":
    main()
