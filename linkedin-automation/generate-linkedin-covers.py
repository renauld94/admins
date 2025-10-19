#!/usr/bin/env python3
"""
LinkedIn Premium Cover Carousel Generator - Hero-Inspired Edition
Creates 5 stunning professional cover images (1128x191px) matching hero animation
Features: Molecular particles, neural networks, cinematic gradients, professional effects
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
import math
import random
from pathlib import Path

# Configuration
WIDTH = 1128
HEIGHT = 191
OUTPUT_DIR = "linkedin-covers"

# Color palette inspired by hero animation & simondatalab.de
COLORS = {
    'bg_dark': '#0f172a',        # Very dark blue (hero base)
    'bg_mid': '#1e293b',         # Dark blue
    'bg_light': '#334155',       # Medium blue
    'accent_cyan': '#0ea5e9',    # Cyan primary
    'accent_purple': '#8b5cf6',  # Purple secondary
    'accent_teal': '#06b6d4',    # Teal accent
    'accent_pink': '#ec4899',    # Pink accent
    'text_white': '#ffffff',     # Pure white
    'text_light': '#cbd5e1',     # Light gray
}


BRAND_EXPORTS = os.path.join(os.path.dirname(__file__), 'brand', 'exports')
BRAND_LOGO = os.path.join(BRAND_EXPORTS, 'simondatalab-logo-96.png')

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 6:
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    return (255, 255, 255)

def create_gradient_background(draw, rect, color1, color2, angle=135):
    """Create smooth diagonal gradient matching hero effect"""
    x1, y1, x2, y2 = rect
    width = x2 - x1
    height = y2 - y1
    
    rgb1 = hex_to_rgb(color1)
    rgb2 = hex_to_rgb(color2)
    
    # Diagonal gradient for hero-like effect
    for y in range(height):
        ratio = y / height
        r = int(rgb1[0] * (1 - ratio) + rgb2[0] * ratio)
        g = int(rgb1[1] * (1 - ratio) + rgb2[1] * ratio)
        b = int(rgb1[2] * (1 - ratio) + rgb2[2] * ratio)
        draw.line([(x1, y1 + y), (x2, y1 + y)], fill=(r, g, b))

def apply_vignette(img, strength=0.35):
    """Apply a subtle radial vignette to focus the eye toward center"""
    width, height = img.size
    vignette = Image.new('L', (width, height), 0)
    vdraw = ImageDraw.Draw(vignette)
    # Elliptical radial gradient mask
    max_radius = int((width + height) / 2)
    steps = 50
    for i in range(steps):
        radius_x = int((width/2) + (i/steps) * (width/2))
        radius_y = int((height/2) + (i/steps) * (height/2))
        alpha = int(255 * (i/steps) * strength)
        bbox = [width//2 - radius_x, height//2 - radius_y, width//2 + radius_x, height//2 + radius_y]
        vdraw.ellipse(bbox, outline=alpha)
    vignette = vignette.filter(ImageFilter.GaussianBlur(25))
    # Create black overlay whose alpha is controlled by vignette mask
    base = img.convert('RGBA')
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    black = Image.new('RGBA', (width, height), (0, 0, 0, 200))
    # Use vignette as alpha for the black overlay
    black.putalpha(vignette)
    # Composite overlay onto base
    result = Image.alpha_composite(base, black)
    return result.convert('RGB')

def draw_neural_mesh(draw, width, height, region='right', nodes=12, line_opacity=28):
    """Draw a subtle neural mesh: faint connections between nodes.
    region: 'right' draws mesh on right third; 'full' uses entire canvas.
    """
    random.seed(77)
    if region == 'right':
        x_min = int(width * 0.62)
        x_max = width - 10
        y_min = 10
        y_max = height - 10
    else:
        x_min = 10; x_max = width - 10; y_min = 10; y_max = height - 10

    pts = []
    for _ in range(nodes):
        pts.append((random.randint(x_min, x_max), random.randint(y_min, y_max)))

    line_color = hex_to_rgb(COLORS['accent_cyan']) + (line_opacity,)
    node_color = hex_to_rgb(COLORS['accent_purple']) + (line_opacity + 10,)

    # Connect each point to a few nearest neighbors
    for i, (x1, y1) in enumerate(pts):
        # Compute distances
        dists = []
        for j, (x2, y2) in enumerate(pts):
            if i == j: continue
            d = (x1 - x2)**2 + (y1 - y2)**2
            dists.append((d, (x2, y2)))
        dists.sort(key=lambda t: t[0])
        for _, (x2, y2) in dists[:3]:
            draw.line([(x1, y1), (x2, y2)], fill=line_color, width=1)
        # Draw node
        draw.ellipse([x1-1, y1-1, x1+1, y1+1], fill=node_color)

def draw_gradient_text(img, text, font, position, gradient_colors):
    """Draw text filled with a horizontal gradient using a text mask."""
    tx, ty = position
    # Create text mask
    mask = Image.new('L', img.size, 0)
    mdraw = ImageDraw.Draw(mask)
    mdraw.text((tx, ty), text, font=font, fill=255)
    # Create gradient image
    grad = Image.new('RGB', img.size)
    gdraw = ImageDraw.Draw(grad)
    c1 = hex_to_rgb(gradient_colors[0])
    c2 = hex_to_rgb(gradient_colors[1])
    for x in range(img.size[0]):
        ratio = x / max(1, img.size[0]-1)
        r = int(c1[0]*(1-ratio) + c2[0]*ratio)
        g = int(c1[1]*(1-ratio) + c2[1]*ratio)
        b = int(c1[2]*(1-ratio) + c2[2]*ratio)
        gdraw.line([(x, 0), (x, img.size[1])], fill=(r, g, b))
    # Composite gradient through mask onto base
    base = img.convert('RGB')
    out = Image.composite(grad, base, mask)
    return out

def rounded_rect(draw: ImageDraw.ImageDraw, bbox, radius=6, fill=None, outline=None, width=1):
    """Draw a rounded rectangle with fallback if Pillow lacks rounded_rectangle."""
    try:
        draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)
    except AttributeError:
        # Fallback to normal rectangle if rounded not available
        draw.rectangle(bbox, fill=fill, outline=outline, width=width)

def add_molecular_particles(draw, width, height, particle_count=60, base_color=COLORS['accent_cyan'], density='medium'):
    """Add refined molecular particle effect - professional, not chaotic
    
    Creates sophisticated particle distribution with:
    - Controlled density (sparse, medium, dense)
    - Subtle glow halos (depth without clutter)
    - Strategic color placement
    - Professional opacity gradients
    """
    random.seed(42)  # Consistent particles for reproducibility
    
    # Adjust particle count by density
    if density == 'sparse':
        particle_count = int(particle_count * 0.5)
    elif density == 'dense':
        particle_count = int(particle_count * 1.3)
    
    # Particle properties - refined for professional look
    particles = []
    for _ in range(particle_count):
        particles.append({
            'x': random.randint(0, width),
            'y': random.randint(0, height),
            'radius': random.choice([0.8, 1.2, 1.5, 2, 2.5, 3]),  # Smaller sizes (more subtle)
            'opacity': random.randint(80, 160),  # More refined opacity range
            'color': random.choice([
                COLORS['accent_cyan'],
                COLORS['accent_purple'],
                COLORS['accent_teal'],
            ])
        })
    
    # Draw particles with subtle glow
    for particle in particles:
        rgb = hex_to_rgb(particle['color'])
        
        # Only add subtle core particle (no excessive halos)
        core_rgb = rgb + (particle['opacity'],)
        draw.ellipse(
            [particle['x'] - particle['radius'], 
             particle['y'] - particle['radius'],
             particle['x'] + particle['radius'], 
             particle['y'] + particle['radius']],
            fill=core_rgb[:3]
        )

def add_hero_grid_pattern(draw, width, height, spacing=50, color=COLORS['accent_cyan'], opacity=8):
    """Add subtle, professional grid pattern from hero visualization"""
    rgb = hex_to_rgb(color)
    
    # Vertical lines - very subtle
    for x in range(0, width, spacing):
        draw.line([(x, 0), (x, height)], fill=rgb + (opacity,), width=1)
    
    # Horizontal lines - very subtle
    for y in range(0, height, spacing):
        draw.line([(0, y), (width, y)], fill=rgb + (opacity,), width=1)

def add_neural_accent(draw, width, height):
    """Add neural network accent lines inspired by hero"""
    # Draw subtle accent lines
    rgb = hex_to_rgb(COLORS['accent_purple'])
    random.seed(123)  # Reproducible pattern
    
    for _ in range(5):
        x1 = random.randint(0, width // 3)
        y1 = random.randint(0, height)
        x2 = random.randint(width * 2 // 3, width)
        y2 = random.randint(0, height)
        draw.line([(x1, y1), (x2, y2)], fill=rgb + (30,), width=1)

def overlay_brand(img, position='top-right', scale=0.18, margin=10):
    """Overlay brand logo on cover"""
    try:
        if not os.path.exists(BRAND_LOGO):
            return img
        
        logo = Image.open(BRAND_LOGO).convert('RGBA')
        target_h = int(HEIGHT * scale)
        target_w = int(logo.width * (target_h / logo.height)) if logo.height > 0 else target_h
        
        # Resize using default high-quality method
        logo = logo.resize((target_w, target_h))
        
        # Calculate position
        if position == 'top-right':
            x = WIDTH - margin - target_w
            y = margin
        elif position == 'top-left':
            x = margin
            y = margin
        elif position == 'bottom-right':
            x = WIDTH - margin - target_w
            y = HEIGHT - margin - target_h
        else:  # bottom-left
            x = margin
            y = HEIGHT - margin - target_h
        
        # Composite
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        img.alpha_composite(logo, (x, y))
    except Exception as e:
        print(f"    ⚠️ Brand overlay skipped: {e}")
    
    return img.convert('RGB') if img.mode == 'RGBA' else img


def create_slide_1_hero():
    """Slide 1: Hero Introduction - Clean, professional, with neural mesh accent"""
    img = Image.new('RGB', (WIDTH, HEIGHT), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Clean gradient background
    create_gradient_background(draw, [0, 0, WIDTH, HEIGHT], 
                              COLORS['bg_dark'], COLORS['bg_light'])
    
    # Add very subtle grid pattern
    add_hero_grid_pattern(draw, WIDTH, HEIGHT, spacing=60, opacity=6)
    
    # Add refined particles (sparse for clean look)
    add_molecular_particles(draw, WIDTH, HEIGHT, particle_count=36, density='sparse')
    # Subtle neural mesh on right
    draw_neural_mesh(draw, WIDTH, HEIGHT, region='right', nodes=14, line_opacity=26)
    
    # No neural accent lines - too busy
    
    # Professional typography
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 56)
        subtitle_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Title - clean and strong
    draw.text((70, 32), "Simon Renauld", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))
    
    # Subtitle - refined
    draw.text((70, 100), "Data Engineering & Analytics Leader", 
             font=subtitle_font, fill=hex_to_rgb(COLORS['text_light']))
    
    # Brand logo overlay
    img = overlay_brand(img, 'top-right', scale=0.2, margin=12)
    # Vignette for focus
    img = apply_vignette(img, strength=0.28)
    return img

def create_slide_2_expertise():
    """Slide 2: Core Expertise - Minimal, professional boxes"""
    img = Image.new('RGB', (WIDTH, HEIGHT), hex_to_rgb(COLORS['bg_mid']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Clean gradient
    create_gradient_background(draw, [0, 0, WIDTH, HEIGHT], 
                              COLORS['bg_mid'], COLORS['bg_light'])
    
    # Minimal particles
    add_molecular_particles(draw, WIDTH, HEIGHT, particle_count=28, density='sparse')
    # Light mesh at far right
    draw_neural_mesh(draw, WIDTH, HEIGHT, region='right', nodes=10, line_opacity=20)
    
    # Professional typography
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
        box_title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)
        box_text_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 10)
    except:
        title_font = ImageFont.load_default()
        box_title_font = ImageFont.load_default()
        box_text_font = ImageFont.load_default()
    
    draw.text((60, 18), "Core Expertise", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))
    
    # Professional expertise boxes - minimal design
    expertise = [
        {'title': 'MLOps', 'desc': 'Production Systems'},
        {'title': 'Data Eng', 'desc': 'Enterprise Scale'},
        {'title': 'Governance', 'desc': 'Compliance'},
        {'title': 'Analytics', 'desc': 'Strategic Intel'}
    ]
    
    box_width = 240
    box_height = 85
    start_x = 55
    start_y = 72
    gap = 20
    
    for i, item in enumerate(expertise):
        x = start_x + (box_width + gap) * i
        y = start_y

        # Clean minimal border (professional)
        border_color = hex_to_rgb(COLORS['accent_cyan']) + (60,)
        fill_color = hex_to_rgb(COLORS['accent_cyan']) + (10,)
        rounded_rect(draw, [x, y, x + box_width, y + box_height], radius=6,
                     fill=fill_color, outline=border_color, width=1)

        # Professional text
        draw.text((x + 12, y + 22), item['title'], font=box_title_font,
                  fill=hex_to_rgb(COLORS['accent_purple']))
        draw.text((x + 12, y + 50), item['desc'], font=box_text_font,
                  fill=hex_to_rgb(COLORS['text_light']))
    
    img = overlay_brand(img, 'top-right', scale=0.2, margin=12)
    img = apply_vignette(img, strength=0.22)
    return img

def create_slide_3_impact():
    """Slide 3: Proven Impact - Bold metrics, professional layout"""
    img = Image.new('RGB', (WIDTH, HEIGHT), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Clean gradient
    create_gradient_background(draw, [0, 0, WIDTH, HEIGHT], 
                              COLORS['bg_dark'], COLORS['bg_mid'])
    
    # Medium particle density for visual interest
    add_molecular_particles(draw, WIDTH, HEIGHT, particle_count=36, density='medium')
    draw_neural_mesh(draw, WIDTH, HEIGHT, region='right', nodes=12, line_opacity=22)
    
    # Professional typography
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
        metric_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 38)
        label_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 11)
    except:
        title_font = ImageFont.load_default()
        metric_font = ImageFont.load_default()
        label_font = ImageFont.load_default()
    
    # Title
    title_text = "Proven Impact"
    title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    draw.text(((WIDTH - title_width) // 2, 12), title_text, font=title_font,
             fill=hex_to_rgb(COLORS['accent_cyan']))
    
    # Metrics - clean and bold
    metrics = [
        {'value': '500M+', 'label': 'Records'},
        {'value': '85%', 'label': 'Faster'},
        {'value': '99.9%', 'label': 'Uptime'},
        {'value': '100%', 'label': 'Compliant'}
    ]
    
    box_width = 245
    box_height = 90
    start_x = 70
    start_y = 60
    gap = 28
    
    for i, metric in enumerate(metrics):
        x = start_x + (box_width + gap) * i
        y = start_y

        # Professional minimal box
        border_color = hex_to_rgb(COLORS['accent_purple']) + (75,)
        fill_color = hex_to_rgb(COLORS['accent_purple']) + (12,)
        rounded_rect(draw, [x, y, x + box_width, y + box_height], radius=6,
                     fill=fill_color, outline=border_color, width=1)

        # Bold metric value
        value_bbox = draw.textbbox((0, 0), metric['value'], font=metric_font)
        value_width = value_bbox[2] - value_bbox[0]
        draw.text((x + (box_width - value_width) // 2, y + 18), metric['value'],
                  font=metric_font, fill=hex_to_rgb(COLORS['accent_purple']))

        # Label
        label_bbox = draw.textbbox((0, 0), metric['label'], font=label_font)
        label_width = label_bbox[2] - label_bbox[0]
        draw.text((x + (box_width - label_width) // 2, y + 68), metric['label'],
                  font=label_font, fill=hex_to_rgb(COLORS['text_light']))
    
    img = overlay_brand(img, 'top-right', scale=0.2, margin=12)
    img = apply_vignette(img, strength=0.22)
    return img

def create_slide_4_techstack():
    """Slide 4: Technology Stack - Professional minimal design"""
    img = Image.new('RGB', (WIDTH, HEIGHT), hex_to_rgb(COLORS['bg_mid']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Clean gradient
    create_gradient_background(draw, [0, 0, WIDTH, HEIGHT],
                              COLORS['bg_mid'], COLORS['bg_dark'])
    
    # Minimal particles
    add_molecular_particles(draw, WIDTH, HEIGHT, particle_count=26, density='sparse')
    draw_neural_mesh(draw, WIDTH, HEIGHT, region='right', nodes=10, line_opacity=18)
    
    # Professional typography
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
        cat_title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 13)
        cat_text_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 9)
    except:
        title_font = ImageFont.load_default()
        cat_title_font = ImageFont.load_default()
        cat_text_font = ImageFont.load_default()
    
    draw.text((60, 18), "Technology Stack", font=title_font, fill=hex_to_rgb(COLORS['accent_cyan']))
    
    # Tech categories - minimal design
    categories = [
        {'title': 'Data', 'tech': 'Airflow, Spark\nKafka, dbt, SQL'},
        {'title': 'ML/AI', 'tech': 'MLflow, TensorFlow\nPyTorch, scikit-learn'},
        {'title': 'Cloud', 'tech': 'AWS, Azure\nKubernetes, Docker'}
    ]
    
    box_width = 335
    box_height = 84
    start_x = 52
    start_y = 72
    gap = 15
    
    for i, cat in enumerate(categories):
        x = start_x + (box_width + gap) * i
        y = start_y

        # Professional minimal box
        border_color = hex_to_rgb(COLORS['accent_teal']) + (70,)
        fill_color = hex_to_rgb(COLORS['accent_teal']) + (10,)
        rounded_rect(draw, [x, y, x + box_width, y + box_height], radius=6,
                     fill=fill_color, outline=border_color, width=1)

        # Category title
        draw.text((x + 14, y + 15), cat['title'], font=cat_title_font,
                  fill=hex_to_rgb(COLORS['accent_teal']))

        # Tech items
        draw.text((x + 14, y + 38), cat['tech'], font=cat_text_font,
                  fill=hex_to_rgb(COLORS['text_light']))
    
    img = overlay_brand(img, 'top-right', scale=0.2, margin=12)
    img = apply_vignette(img, strength=0.22)
    return img

def create_slide_5_cta():
    """Slide 5: Call to Action - Bold, professional, impactful"""
    img = Image.new('RGB', (WIDTH, HEIGHT), hex_to_rgb(COLORS['bg_dark']))
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Gradient for visual interest
    create_gradient_background(draw, [0, 0, WIDTH, HEIGHT],
                              COLORS['bg_dark'], COLORS['bg_light'])
    
    # Medium particles for cinematic feel
    add_molecular_particles(draw, WIDTH, HEIGHT, particle_count=40, density='medium')
    draw_neural_mesh(draw, WIDTH, HEIGHT, region='right', nodes=12, line_opacity=20)
    
    # Professional typography
    try:
        main_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 46)
        subtitle_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
        email_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
    except:
        main_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        email_font = ImageFont.load_default()
    
    # Main CTA - bold gradient text
    main_text = "Transform Data Into Value"
    main_bbox = draw.textbbox((0, 0), main_text, font=main_font)
    main_width = main_bbox[2] - main_bbox[0]
    tx = (WIDTH - main_width) // 2
    ty = 22
    tmp = draw_gradient_text(img, main_text, main_font, (tx, ty),
                             [COLORS['accent_cyan'], COLORS['accent_purple']])
    img = tmp
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Subtitle
    subtitle_text = "Strategic consulting & technical leadership"
    subtitle_bbox = draw.textbbox((0, 0), subtitle_text, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    draw.text(((WIDTH - subtitle_width) // 2, 80), subtitle_text, font=subtitle_font,
             fill=hex_to_rgb(COLORS['text_light']))
    
    # Professional contact
    email_text = "simon@simondatalab.de"
    email_bbox = draw.textbbox((0, 0), email_text, font=email_font)
    email_width = email_bbox[2] - email_bbox[0]
    draw.text(((WIDTH - email_width) // 2, 128), email_text, font=email_font,
             fill=hex_to_rgb(COLORS['accent_pink']))
    
    img = overlay_brand(img, 'top-right', scale=0.2, margin=12)
    img = apply_vignette(img, strength=0.25)
    return img

def main():
    """Generate all 5 hero-inspired slides"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print("🎬 Generating LinkedIn Premium Cover Carousel (Hero-Inspired)")
    print("=" * 70)
    print(f"📐 Dimensions: {WIDTH}x{HEIGHT}px")
    print(f"📁 Output: {OUTPUT_DIR}/")
    print(f"🎨 Style: Molecular particles, neural networks, cinematic gradients")
    print()
    
    slides = [
        ("Slide 1: Hero Introduction", create_slide_1_hero),
        ("Slide 2: Core Expertise", create_slide_2_expertise),
        ("Slide 3: Proven Impact", create_slide_3_impact),
        ("Slide 4: Technology Stack", create_slide_4_techstack),
        ("Slide 5: Call to Action", create_slide_5_cta)
    ]
    
    for i, (name, create_func) in enumerate(slides, 1):
        print(f"  Creating {name}...")
        try:
            img = create_func()
            filename = os.path.join(OUTPUT_DIR, f"simon-renauld-linkedin-cover-slide-{i}.png")
            img.save(filename, 'PNG', optimize=True)
            file_size_kb = os.path.getsize(filename) / 1024
            print(f"    ✅ Saved: {filename} ({file_size_kb:.1f} KB)")
        except Exception as e:
            print(f"    ❌ Error: {e}")
    
    print()
    print("🎉 All slides generated successfully!")
    print(f"📤 Ready to upload to LinkedIn Premium Cover (in order, slide 1-5)")
    print()

if __name__ == "__main__":
    main()
