#!/usr/bin/env python3
"""
LinkedIn Carousel Generator - AI Homelab Edition
Creates a professional PDF carousel (1080x1080px per slide) matching simondatalab.de style
Content: ProxmoxMCP + Skywork AI implementation
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
from pathlib import Path

# LinkedIn Carousel Specs
SLIDE_SIZE = 1080  # 1080x1080px square
OUTPUT_DIR = "linkedin-covers/carousel"
OUTPUT_PDF = "AI-Homelab-LinkedIn-Carousel.pdf"

# Brand colors from simondatalab.de
COLORS = {
    'bg_dark': '#0f172a',
    'bg_mid': '#1e293b',
    'bg_light': '#334155',
    'accent_cyan': '#0ea5e9',
    'accent_purple': '#8b5cf6',
    'accent_teal': '#06b6d4',
    'text_white': '#ffffff',
    'text_light': '#cbd5e1',
}

BRAND_EXPORTS = os.path.join(os.path.dirname(__file__), 'brand', 'exports')
BRAND_LOGO = os.path.join(BRAND_EXPORTS, 'simondatalab-logo-96.png')

def hex_to_rgb(hex_color):
    """Convert hex to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_gradient_background(draw, color1, color2, size=SLIDE_SIZE):
    """Create diagonal gradient"""
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    
    for y in range(size):
        ratio = y / size
        r = int(rgb1[0] * (1 - ratio) + rgb2[0] * ratio)
        g = int(rgb1[1] * (1 - ratio) + rgb2[1] * ratio)
        b = int(rgb1[2] * (1 - ratio) + rgb2[2] * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

def add_particles(draw, size=SLIDE_SIZE, count=40):
    """Add subtle molecular particles"""
    import random
    random.seed(42)
    
    for _ in range(count):
        x = random.randint(0, size)
        y = random.randint(0, size)
        radius = random.choice([1, 1.5, 2, 2.5])
        opacity = random.randint(80, 150)
        color = random.choice([COLORS['accent_cyan'], COLORS['accent_purple'], COLORS['accent_teal']])
        rgb = hex_to_rgb(color)
        draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=rgb)

def add_logo(img, position='top-right', margin=40):
    """Add brand logo"""
    try:
        if not os.path.exists(BRAND_LOGO):
            return img
        
        logo = Image.open(BRAND_LOGO).convert('RGBA')
        target_h = 80
        target_w = int(logo.width * (target_h / logo.height))
        logo = logo.resize((target_w, target_h))
        
        if position == 'top-right':
            x = SLIDE_SIZE - margin - target_w
            y = margin
        else:
            x = margin
            y = margin
        
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        img.alpha_composite(logo, (x, y))
    except Exception as e:
        print(f"Logo overlay skipped: {e}")
    
    return img.convert('RGB')

def get_fonts():
    """Load fonts with fallback"""
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 80)
        heading_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 56)
        subhead_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 38)
        body_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 28)
        small_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
        return title_font, heading_font, subhead_font, body_font, small_font
    except:
        default = ImageFont.load_default()
        return default, default, default, default, default

def create_slide_1_hero():
    """Slide 1: Hero intro — what/why/value"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_dark'], COLORS['bg_mid'])
    add_particles(draw, count=35)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Title
    draw.text((80, 280), "AI-Native Homelab", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))

    # Subtitles
    draw.text((80, 420), "Private, cost-efficient MLOps you control", 
             font=subhead_font, fill=hex_to_rgb(COLORS['text_white']))
    draw.text((80, 480), "What it is • Why it matters • What you get", 
             font=body_font, fill=hex_to_rgb(COLORS['text_light']))

    # Tech line
    draw.text((80, 560), "Powered by ProxmoxMCP + Model Context Protocol", 
             font=small_font, fill=hex_to_rgb(COLORS['text_light']))
    
    # Bottom text
    draw.text((80, 920), "Simon Renauld", font=subhead_font, fill=hex_to_rgb(COLORS['text_white']))
    draw.text((80, 975), "Data Engineering Leader • simondatalab.de", font=small_font, fill=hex_to_rgb(COLORS['text_light']))
    
    img = add_logo(img)
    return img

def create_slide_2_problem():
    """Slide 2: The Challenge — pain points and objective"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_mid']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_mid'], COLORS['bg_dark'])
    add_particles(draw, count=30)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Title
    draw.text((80, 100), "The Challenge", font=heading_font, fill=hex_to_rgb(COLORS['accent_purple']))

    # Challenges list
    challenges = [
        "Slow idea → experiment cycles (days, not hours)",
        "Unpredictable cloud costs for iteration",
        "Data residency/privacy constraints",
        "Fragmented tooling across teams"
    ]

    y = 250
    for challenge in challenges:
        draw.text((80, y), "•", font=subhead_font, fill=hex_to_rgb(COLORS['accent_cyan']))
        draw.text((140, y), challenge, font=body_font, fill=hex_to_rgb(COLORS['text_white']))
        y += 110

    # Objective line
    draw.text((80, 720), "Objective", font=subhead_font, fill=hex_to_rgb(COLORS['accent_teal']))
    draw.text((80, 770), "Make experiments fast, affordable, and compliant — on your own hardware.",
              font=body_font, fill=hex_to_rgb(COLORS['text_light']))
    
    img = add_logo(img)
    return img

def create_slide_3_solution():
    """Slide 3: The Solution — what I built and how it works"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_dark'], COLORS['bg_light'])
    add_particles(draw, count=40)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Title
    draw.text((80, 100), "The Solution", font=heading_font, fill=hex_to_rgb(COLORS['accent_cyan']))

    # Solution components
    solutions = [
        ("What it is", "An AI-managed Proxmox platform (ProxmoxMCP + MCP)"),
        ("How it works", "Agents provision test VMs per PR, run checks, and clean up"),
        ("For ML", "On‑demand GPU VMs; training and inference spin up only when needed"),
        ("Operations", "Health checks, logs, and alerts wired into Grafana/MLflow")
    ]

    y = 270
    for title, desc in solutions:
        draw.text((80, y), title, font=subhead_font, fill=hex_to_rgb(COLORS['accent_purple']))
        draw.text((80, y + 48), desc, font=body_font, fill=hex_to_rgb(COLORS['text_light']))
        y += 150
    
    img = add_logo(img)
    return img

def create_slide_4_results():
    """Slide 4: Results & Impact — example outcomes"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_mid']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_mid'], COLORS['bg_dark'])
    add_particles(draw, count=35)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Title
    draw.text((80, 100), "Example Outcomes", font=heading_font, fill=hex_to_rgb(COLORS['accent_teal']))

    # Metrics (illustrative)
    metrics = [
        ("< 2 min", "VM provisioning time"),
        ("50%", "fewer manual interventions"),
        ("20%", "lower power/capacity overhead"),
        ("~5 min", "mean incident response")
    ]
    
    y = 280
    for i, (value, label) in enumerate(metrics):
        if i % 2 == 0:
            x = 80
        else:
            x = 560
            y -= 200

        # Metric box
        draw.rectangle([x, y, x + 420, y + 180],
                       outline=hex_to_rgb(COLORS['accent_teal']), width=2)

        draw.text((x + 30, y + 30), value, font=heading_font,
                  fill=hex_to_rgb(COLORS['accent_teal']))
        draw.text((x + 30, y + 110), label, font=body_font,
                  fill=hex_to_rgb(COLORS['text_light']))

        y += 250
    
    img = add_logo(img)
    return img

def create_slide_5_tech():
    """Slide 5: Use Cases — tangible objectives and examples"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_dark'], COLORS['bg_mid'])
    add_particles(draw, count=30)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Title
    draw.text((80, 100), "Use Cases", font=heading_font, fill=hex_to_rgb(COLORS['accent_purple']))

    # Concrete examples (illustrative)
    use_cases = [
        ("Private RAG", "Answer docs/Q&A without sending data to cloud"),
        ("Analytics to Insight", "ETL → model → Grafana dashboard in a day"),
        ("ML Experimentation", "Run 10–20 safe experiments/day on fixed budget"),
        ("On‑prem Inference", "Latency‑sensitive apps, GPU only when needed"),
        ("Governed Prototyping", "Keep PII/data in‑house while iterating fast")
    ]

    y = 260
    for title, desc in use_cases:
        draw.text((80, y), title, font=subhead_font, fill=hex_to_rgb(COLORS['accent_cyan']))
        draw.text((80, y + 46), desc, font=small_font, fill=hex_to_rgb(COLORS['text_light']))
        y += 170
    
    img = add_logo(img)
    return img

def create_slide_6_cta():
    """Slide 6: Call to Action — professional close"""
    img = Image.new('RGB', (SLIDE_SIZE, SLIDE_SIZE), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    create_gradient_background(draw, COLORS['bg_dark'], COLORS['bg_light'])
    add_particles(draw, count=45)
    
    title_font, heading_font, subhead_font, body_font, small_font = get_fonts()
    
    # Main message
    draw.text((80, 300), "Build an AI‑Native", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))
    draw.text((80, 400), "Platform that Pays Off", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))

    # CTA bullets
    bullets = [
        "30–90 day roadmap",
        "Fixed, transparent budget",
        "On‑prem or hybrid cloud"
    ]
    y = 620
    for b in bullets:
        draw.text((80, y), "•", font=subhead_font, fill=hex_to_rgb(COLORS['accent_teal']))
        draw.text((140, y), b, font=body_font, fill=hex_to_rgb(COLORS['text_light']))
        y += 70

    # Contact
    draw.text((80, 920), "Simon Renauld", font=subhead_font, fill=hex_to_rgb(COLORS['text_white']))
    draw.text((80, 970), "linkedin.com/in/simonrenauld  •  simondatalab.de", font=small_font, fill=hex_to_rgb(COLORS['accent_purple']))
    
    img = add_logo(img)
    return img

def main():
    """Generate carousel and save as PDF"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print("🎨 Generating AI Homelab LinkedIn Carousel")
    print("=" * 60)
    print(f"📐 Size: {SLIDE_SIZE}x{SLIDE_SIZE}px per slide")
    print(f"📁 Output: {OUTPUT_DIR}/")
    print()
    
    slides = [
        ("Slide 1: Hero", create_slide_1_hero),
        ("Slide 2: Challenge", create_slide_2_problem),
        ("Slide 3: Solution", create_slide_3_solution),
        ("Slide 4: Results", create_slide_4_results),
    ("Slide 5: Use Cases", create_slide_5_tech),
        ("Slide 6: CTA", create_slide_6_cta)
    ]
    
    images = []
    for i, (name, create_func) in enumerate(slides, 1):
        print(f"  Creating {name}...")
        try:
            img = create_func()
            filename = os.path.join(OUTPUT_DIR, f"slide-{i}.png")
            img.save(filename, 'PNG', optimize=True)
            images.append(img)
            file_size_kb = os.path.getsize(filename) / 1024
            print(f"    ✅ Saved: {filename} ({file_size_kb:.1f} KB)")
        except Exception as e:
            print(f"    ❌ Error: {e}")
    
    # Save as PDF
    if images:
        pdf_path = os.path.join(OUTPUT_DIR, OUTPUT_PDF)
        images[0].save(
            pdf_path, 
            "PDF", 
            resolution=100.0, 
            save_all=True, 
            append_images=images[1:]
        )
        pdf_size_kb = os.path.getsize(pdf_path) / 1024
        print()
        print(f"📄 PDF Created: {pdf_path} ({pdf_size_kb:.1f} KB)")
        print()
        print("🎉 Ready to upload to LinkedIn!")
        print("   Upload as document/carousel post")
        print()

if __name__ == "__main__":
    main()
