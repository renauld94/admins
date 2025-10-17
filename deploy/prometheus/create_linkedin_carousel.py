#!/usr/bin/env python3
"""
LinkedIn Carousel PDF Generator
Creates a professional carousel PDF styled like simondatalab.de
"""

from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.platypus import Paragraph, Frame
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import ImageReader
import os
import subprocess
from shutil import which

# LinkedIn carousel dimensions (1080x1080 pixels = 10x10 inches at 108 DPI)
PAGE_SIZE = (10*inch, 10*inch)
MARGIN = 0.8 * inch
SAFE_TOP = MARGIN
SAFE_BOTTOM = 1.0 * inch  # leave space for footer

# Color scheme inspired by simondatalab.de
COLOR_DARK_BG = colors.HexColor('#0a0f1a')  # Dark navy background
COLOR_ACCENT = colors.HexColor('#00d4ff')   # Cyan accent
COLOR_TEXT_PRIMARY = colors.HexColor('#e8eaed')  # Light gray text
COLOR_TEXT_SECONDARY = colors.HexColor('#9ca3af')  # Medium gray text
COLOR_HIGHLIGHT = colors.HexColor('#3b82f6')  # Blue highlight

class LinkedInCarousel:
    def __init__(self, output_path):
        self.output_path = output_path
        self.c = canvas.Canvas(output_path, pagesize=PAGE_SIZE)
        self.width, self.height = PAGE_SIZE
        self.styles = self._build_styles()
        self.assets_dir = os.path.join(os.path.dirname(output_path), 'assets')
        os.makedirs(self.assets_dir, exist_ok=True)
        # Default image paths
        self.img_grafana = os.path.join(self.assets_dir, 'grafana_node_exporter_24h.png')
        self.img_openwebui = os.path.join(self.assets_dir, 'openwebui_home.png')

    def _build_styles(self):
        styles = getSampleStyleSheet()
        styles.add(ParagraphStyle(
            name='TitleLarge', fontName='Helvetica-Bold', fontSize=48,
            leading=52, textColor=COLOR_TEXT_PRIMARY, alignment=TA_CENTER,
            spaceAfter=18
        ))
        styles.add(ParagraphStyle(
            name='Subtitle', fontName='Helvetica', fontSize=24,
            leading=30, textColor=COLOR_TEXT_SECONDARY, alignment=TA_CENTER,
            spaceAfter=12
        ))
        styles.add(ParagraphStyle(
            name='H2', fontName='Helvetica-Bold', fontSize=32,
            leading=36, textColor=COLOR_TEXT_PRIMARY, alignment=TA_CENTER,
            spaceAfter=20
        ))
        styles.add(ParagraphStyle(
            name='H3', fontName='Helvetica-Bold', fontSize=20,
            leading=24, textColor=COLOR_ACCENT, alignment=TA_LEFT, spaceAfter=8
        ))
        styles.add(ParagraphStyle(
            name='Body', fontName='Helvetica', fontSize=16, leading=22,
            textColor=COLOR_TEXT_PRIMARY, alignment=TA_LEFT
        ))
        styles.add(ParagraphStyle(
            name='BodySecondary', fontName='Helvetica', fontSize=14, leading=20,
            textColor=COLOR_TEXT_SECONDARY, alignment=TA_LEFT
        ))
        styles.add(ParagraphStyle(
            name='Bullets', fontName='Helvetica', fontSize=16, leading=22,
            textColor=COLOR_TEXT_PRIMARY, leftIndent=18, bulletIndent=6
        ))
        return styles
        
    def add_page(self, page_func):
        """Add a new page to the carousel"""
        page_func()
        self.c.showPage()
    
    def draw_background(self):
        """Draw dark background with a subtle grid pattern to match site aesthetic."""
        # Base
        self.c.setFillColor(COLOR_DARK_BG)
        self.c.rect(0, 0, self.width, self.height, fill=True, stroke=False)
        
        # Radial gradient effect (simulated with concentric circles)
        center_x = self.width / 2
        center_y = self.height / 2
        max_radius = self.width * 0.7
        for i in range(5):
            alpha = 0.03 - (i * 0.005)
            radius = max_radius - (i * 100)
            self.c.setFillColorRGB(0, 0.83, 1, alpha=alpha)
            self.c.circle(center_x, center_y, radius, fill=True, stroke=False)
        
        # Subtle grid dots with varying opacity
        self.c.setFillColor(colors.HexColor('#0d1320'))
        step = 22
        r = 0.8
        y = SAFE_BOTTOM + 1.2*inch
        while y < self.height - 0.8*inch:
            x = MARGIN
            while x < self.width - MARGIN:
                self.c.circle(x, y, r, fill=True, stroke=False)
                x += step
            y += step
        
        # Premium accent bar at top with gradient
        self.c.setFillColor(colors.HexColor('#0b1626'))
        self.c.rect(0, self.height - 0.35*inch, self.width, 0.35*inch, fill=True, stroke=False)
        self.c.setFillColorRGB(0, 0.83, 1, alpha=0.1)
        self.c.rect(0, self.height - 0.05*inch, self.width, 0.05*inch, fill=True, stroke=False)
    
    def draw_footer(self, page_num, total_pages):
        """Draw footer with page number and branding"""
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", 10)
        self.c.drawCentredString(self.width/2, 0.5*inch, 
                                f"{page_num}/{total_pages}")
        
        # Add subtle branding
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 11)
        self.c.drawRightString(self.width - 0.5*inch, 0.5*inch, 
                              "simondatalab.de")
    
    def draw_title(self, text, y_pos, size=48):
        """Draw a title with accent line"""
        # Draw drop shadow
        self.c.setFillColor(colors.HexColor('#0a0f1a'))
        self.c.setFont("Helvetica-Bold", size)
        text_width = self.c.stringWidth(text, "Helvetica-Bold", size)
        x_pos = (self.width - text_width) / 2
        self.c.drawString(x_pos + 2, y_pos - 2, text)
        # Main title
        self.c.setFillColor(COLOR_TEXT_PRIMARY)
        self.c.drawString(x_pos, y_pos, text)
        # Glowing accent line
        line_width = text_width * 0.7
        line_x = (self.width - line_width) / 2
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(4)
        self.c.line(line_x, y_pos - 18, line_x + line_width, y_pos - 18)
        # Simulate glow by overlaying a lighter accent
        self.c.setStrokeColor(colors.HexColor('#5ffcff'))
        self.c.setLineWidth(1.5)
        self.c.line(line_x, y_pos - 18, line_x + line_width, y_pos - 18)

    def draw_subtitle(self, text, y_pos, size=24):
        """Draw subtitle text"""
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", size)
        text_width = self.c.stringWidth(text, "Helvetica", size)
        x_pos = (self.width - text_width) / 2
        self.c.drawString(x_pos, y_pos, text)
    
    def draw_text_block(self, text, x, y, width, font_size=14, 
                       font="Helvetica", color=COLOR_TEXT_PRIMARY):
        """Draw a block of text with automatic wrapping using simple word wrapping.
        Returns the new y position after the paragraph.
        """
        self.c.setFillColor(color)
        self.c.setFont(font, font_size)
        
        # Simple text wrapping
        words = text.split()
        lines = []
        current_line = []
        
        for word in words:
            test_line = ' '.join(current_line + [word])
            if self.c.stringWidth(test_line, font, font_size) <= width:
                current_line.append(word)
            else:
                if current_line:
                    lines.append(' '.join(current_line))
                current_line = [word]
        if current_line:
            lines.append(' '.join(current_line))
        
        # Draw lines
        line_height = font_size * 1.5
        for i, line in enumerate(lines):
            self.c.drawString(x, y - (i * line_height), line)
        
        return y - (len(lines) * line_height)
    
    def draw_bullet_points(self, points, x, y, width, font_size=14):
        """Draw bullet points with professional styling"""
        for point in points:
            if y < SAFE_BOTTOM + 0.5*inch:  # Safety check
                break
            # Draw bullet
            self.c.setFillColor(COLOR_ACCENT)
            self.c.circle(x, y + font_size/3, 2, fill=True, stroke=False)
            
            # Draw text with wrapping
            text_x = x + 20
            text_width = width - 20
            y_before = y
            y = self.draw_text_block(point, text_x, y, text_width,
                                     font_size, color=COLOR_TEXT_PRIMARY)
            y -= 12  # Space between points
        
        return y

    def draw_loading_motif(self, x, y, width, height):
        """Draw a branded loading motif card inspired by the site's r3f-loading component."""
        # Premium card with outer glow
        self.c.setFillColorRGB(0, 0.83, 1, alpha=0.08)
        self.c.roundRect(x - 4, y - height - 4, width + 8, height + 8, 14, fill=True, stroke=False)
        
        # Card background with gradient layers
        self.c.setFillColor(colors.HexColor('#0f172a'))
        self.c.roundRect(x, y - height, width, height, 12, fill=True, stroke=False)
        
        # Gradient overlay
        self.c.setFillColorRGB(0, 0.4, 0.6, alpha=0.05)
        self.c.roundRect(x, y - height, width, height/2, 12, fill=True, stroke=False)
        
        # Main border with glow
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(2.5)
        self.c.roundRect(x, y - height, width, height, 12, fill=False, stroke=True)
        
        # Inner glow
        self.c.setStrokeColor(colors.HexColor('#5ffcff'))
        self.c.setLineWidth(1)
        self.c.roundRect(x + 4, y - height + 4, width - 8, height - 8, 10, fill=False, stroke=True)
        
        # Enhanced spinner motif with multiple glow layers
        cx = x + 0.6*inch
        cy = y - height/2
        r1 = 0.35*inch
        r2 = 0.5*inch
        
        # Outer arc with glow
        self.c.setStrokeColorRGB(0, 0.83, 1, alpha=0.3)
        self.c.setLineWidth(5)
        self.c.arc(cx - r2, cy - r2, cx + r2, cy + r2, startAng=20, extent=100)
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(3)
        self.c.arc(cx - r2, cy - r2, cx + r2, cy + r2, startAng=20, extent=100)
        self.c.setStrokeColor(colors.HexColor('#5ffcff'))
        self.c.setLineWidth(1.5)
        self.c.arc(cx - r2, cy - r2, cx + r2, cy + r2, startAng=20, extent=100)
        
        # Inner arc with glow
        self.c.setStrokeColorRGB(0, 0.83, 1, alpha=0.3)
        self.c.setLineWidth(4)
        self.c.arc(cx - r1, cy - r1, cx + r1, cy + r1, startAng=200, extent=100)
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(2)
        self.c.arc(cx - r1, cy - r1, cx + r1, cy + r1, startAng=200, extent=100)
        self.c.setStrokeColor(colors.HexColor('#5ffcff'))
        self.c.setLineWidth(1)
        self.c.arc(cx - r1, cy - r1, cx + r1, cy + r1, startAng=200, extent=100)
        
        # Text block with enhanced styling
        text_x = cx + 0.7*inch
        title = "Initializing Data Intelligence Platform..."
        subtitle = "From neural networks to global data networks"
        
        # Title with subtle shadow
        self.c.setFillColor(colors.HexColor('#0a0f1a'))
        self.c.setFont("Helvetica-Bold", 16)
        self.c.drawString(text_x + 1, cy + 13, title)
        self.c.setFillColor(COLOR_TEXT_PRIMARY)
        self.c.drawString(text_x, cy + 14, title)
        
        # Subtitle with glow
        self.c.setFillColor(colors.HexColor('#5ffcff'))
        self.c.setFont("Helvetica", 12)
        self.c.drawString(text_x, cy - 6, subtitle)

    def draw_card(self, x, y_top, width, height, radius=12, with_border=True, accent_top=True):
        """Reusable card component styled like simondatalab.de
        - x, y_top: top-left origin (like text layout)
        - width, height: card size
        - radius: corner radius
        - with_border: draw subtle outer border
        - accent_top: draw cyan accent line near top edge
        Returns the bottom y of the card.
        """
        # Shadow/back layer
        self.c.setFillColor(colors.HexColor('#0d1117'))
        self.c.roundRect(x + 2, y_top - height + 2, width, height, radius, fill=True, stroke=False)

        # Main card
        self.c.setFillColor(colors.HexColor('#1f2937'))
        if with_border:
            self.c.setStrokeColor(colors.HexColor('#374151'))
            self.c.setLineWidth(1)
            self.c.roundRect(x, y_top - height, width, height, radius, fill=True, stroke=True)
        else:
            self.c.roundRect(x, y_top - height, width, height, radius, fill=True, stroke=False)

        # Accent line
        if accent_top:
            self.c.setStrokeColor(COLOR_ACCENT)
            self.c.setLineWidth(3)
            self.c.line(x + 15, y_top - 14, x + width - 15, y_top - 14)

        return y_top - height

    def draw_image(self, path, x, y, width, height, corner=10):
        """Draw an image maintaining aspect ratio inside a rounded rectangle area. Returns bottom y of the image area."""
        # Background card
        self.c.setFillColor(colors.HexColor('#111827'))
        self.c.roundRect(x, y - height, width, height, corner, fill=True, stroke=False)
        if not os.path.exists(path):
            # Placeholder
            self.c.setStrokeColor(COLOR_ACCENT)
            self.c.setLineWidth(1.5)
            self.c.roundRect(x, y - height, width, height, corner, fill=False, stroke=True)
            self.c.setFillColor(COLOR_TEXT_SECONDARY)
            self.c.setFont("Helvetica", 12)
            self.c.drawCentredString(x + width/2, y - height/2, "Image not available")
            return y - height
        try:
            img = ImageReader(path)
            iw, ih = img.getSize()
            # Fit into width x height while preserving aspect
            scale = min(width / iw, height / ih)
            draw_w, draw_h = iw * scale, ih * scale
            dx = x + (width - draw_w) / 2
            dy = y - (height - draw_h) / 2 - draw_h
            self.c.drawImage(img, dx, dy, draw_w, draw_h, mask='auto')
        except Exception:
            # Fallback placeholder
            self.c.setStrokeColor(COLOR_ACCENT)
            self.c.roundRect(x, y - height, width, height, corner, fill=False, stroke=True)
        return y - height

    def try_capture_screenshot(self, url, output_path, width=1600, height=900):
        """Attempt to capture a headless screenshot of a URL using available Chromium/Chrome.
        Returns True if successful, else False.
        """
        if os.path.exists(output_path):
            return True
        browser = which('chromium-browser') or which('chromium') or which('google-chrome') or which('chrome')
        if not browser:
            return False
        cmd = [browser, '--headless=new', '--disable-gpu', '--no-sandbox',
               f'--window-size={width},{height}', f'--screenshot={output_path}', url]
        try:
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=12)
            return os.path.exists(output_path) and os.path.getsize(output_path) > 0
        except Exception:
            return False
    
    def draw_metric_box(self, value, label, x, y, width):
        """Draw a metric box with value and label"""
        box_height = 80
        
        # Draw box background
        self.c.setFillColor(colors.HexColor('#1a1f2e'))
        self.c.roundRect(x, y, width, box_height, 8, fill=True, stroke=False)
        
        # Draw value
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 32)
        text_width = self.c.stringWidth(value, "Helvetica-Bold", 32)
        self.c.drawString(x + (width - text_width)/2, y + 45, value)
        
        # Draw label
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", 12)
        text_width = self.c.stringWidth(label, "Helvetica", 12)
        self.c.drawString(x + (width - text_width)/2, y + 20, label)
    
    # PAGE 1: Cover
    def page_cover(self):
        self.draw_background()
        
        # Main title - premium styling with multiple layers
        self.draw_title("Optimizing AI Models & Agents", self.height - 1.2*inch, 36)
        self.draw_title("on Proxmox", self.height - 1.65*inch, 36)
        
        # Subtitle - smaller and repositioned
        self.draw_subtitle("Production observability for latency, throughput, and reliability", 
                          self.height - 2.15*inch, 14)
        
        # Key visual element - enhanced neural network style diagram
        center_y = self.height/2 + 0.8*inch
        
        # Draw particle effects around diagram
        import random
        random.seed(42)
        for _ in range(30):
            px = self.width/2 + random.uniform(-2.5*inch, 2.5*inch)
            py = center_y + random.uniform(-1.8*inch, 1.8*inch)
            pr = random.uniform(1, 3)
            self.c.setFillColorRGB(0, 0.83, 1, alpha=random.uniform(0.1, 0.3))
            self.c.circle(px, py, pr, fill=True, stroke=False)
        
        # Draw enhanced diagram boxes with glow
        box_width = 2.2*inch
        box_height = 0.6*inch
        
        components = [
            ("Prometheus", center_y + 1.0*inch),
            ("Grafana", center_y),
            ("Node Exporter", center_y - 1.0*inch)
        ]
        
        for comp_name, comp_y in components:
            x = (self.width - box_width) / 2
            
            # Outer glow
            self.c.setFillColorRGB(0, 0.83, 1, alpha=0.15)
            self.c.roundRect(x - 3, comp_y - box_height/2 - 3, box_width + 6, box_height + 6, 
                           10, fill=True, stroke=False)
            
            # Box with enhanced styling
            self.c.setFillColor(colors.HexColor('#1a1f2e'))
            self.c.setStrokeColor(COLOR_ACCENT)
            self.c.setLineWidth(2)
            self.c.roundRect(x, comp_y - box_height/2, box_width, box_height, 
                           8, fill=True, stroke=True)
            
            # Inner glow line
            self.c.setStrokeColor(colors.HexColor('#5ffcff'))
            self.c.setLineWidth(1)
            self.c.roundRect(x + 2, comp_y - box_height/2 + 2, box_width - 4, box_height - 4, 
                           6, fill=False, stroke=True)
            
            # Text
            self.c.setFillColor(COLOR_TEXT_PRIMARY)
            self.c.setFont("Helvetica-Bold", 16)
            text_width = self.c.stringWidth(comp_name, "Helvetica-Bold", 16)
            self.c.drawString(x + (box_width - text_width)/2, 
                            comp_y - 4, comp_name)
            
            # Draw glowing connecting lines
            if comp_name != "Node Exporter":
                line_x = self.width/2
                line_y1 = comp_y - box_height/2 - 8
                line_y2 = comp_y - box_height/2 - 42
                
                # Glow layer
                self.c.setStrokeColorRGB(0, 0.83, 1, alpha=0.3)
                self.c.setLineWidth(4)
                self.c.line(line_x, line_y1, line_x, line_y2)
                
                # Main line
                self.c.setStrokeColor(COLOR_ACCENT)
                self.c.setLineWidth(2)
                self.c.line(line_x, line_y1, line_x, line_y2)
        
        # Loading motif card at bottom - move higher
        motif_width = self.width - 2*MARGIN
        motif_height = 1.1*inch
        motif_y = SAFE_BOTTOM + 2.2*inch  # was 1.5*inch
        self.draw_loading_motif(MARGIN, motif_y, motif_width, motif_height)
        
        # Author - move lower
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", 14)
        self.c.drawCentredString(self.width/2, SAFE_BOTTOM + 0.6*inch, "Simon Renauld")
        self.c.setFont("Helvetica", 12)
        self.c.drawCentredString(self.width/2, SAFE_BOTTOM + 0.35*inch, "Data Engineering & MLOps")
        
        self.draw_footer(1, 8)
    
    # PAGE 2: The Challenge
    def page_challenge(self):
        self.draw_background()
        
        self.draw_title("The Optimization Challenge", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.4*inch
        
        # Problem statement
        problem_text = (
            "Model inference latency spikes, inconsistent tokens/s, and memory pressure on Proxmox VMs. "
            "Agent orchestration adds overhead, with limited visibility across containers and host resources. "
            "Capacity planning is reactive rather than data-driven."
        )
        
        # Enhanced problem card background with border
        card_x = MARGIN
        card_w = self.width - 2*MARGIN
        card_h = 1.8*inch

        # Outer border for depth effect
        self.c.setFillColor(colors.HexColor('#0d1117'))
        self.c.roundRect(card_x + 2, y_pos - card_h + 2, card_w, card_h, 12, fill=True, stroke=False)

        # Main card with subtle border
        self.c.setFillColor(colors.HexColor('#1f2937'))
        self.c.setStrokeColor(colors.HexColor('#374151'))
        self.c.setLineWidth(1)
        self.c.roundRect(card_x, y_pos - card_h, card_w, card_h, 12, fill=True, stroke=True)

        # Accent line moved higher (top edge)
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(3)
        self.c.line(card_x + 15, y_pos - 8, card_x + card_w - 15, y_pos - 8)

        # Add more top padding before text block
        y_text_start = y_pos - 0.6*inch
        y_pos = self.draw_text_block(problem_text, card_x + 0.4*inch, y_text_start, 
                     card_w - 0.8*inch, 15, 
                     "Helvetica", COLOR_TEXT_PRIMARY)
        
        y_pos = self.height - 4.5*inch
        
        # Requirements
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 20)
        self.c.drawString(MARGIN, y_pos, "Optimization Requirements")
        
        y_pos -= 0.5*inch
        
        requirements = [
            "p95/p99 latency and tokens/s visibility for model endpoints",
            "CPU/GPU/memory utilization with container and host breakdown",
            "Disk I/O and network saturation detection under load",
            "Agent orchestration metrics (queue depth, concurrency, retries)",
            "Historical trends for capacity planning on Proxmox"
        ]
        
        y_pos = self.draw_bullet_points(requirements, MARGIN, y_pos, 
                                         self.width - 2*MARGIN, 15)
        
        self.draw_footer(2, 8)
    
    # PAGE 3: The Solution
    def page_solution(self):
        self.draw_background()
        
        self.draw_title("The Solution", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.4*inch
        
        # Solution overview
        solution_text = (
            "A production observability stack on Proxmox: Prometheus scrapes host and container metrics; "
            "Grafana provides real-time dashboards and alerts; Node Exporter and cAdvisor expose system and container stats; "
            "OpenWebUI/Ollama performance observed via system signals for model throughput and latency optimization."
        )
        
        y_pos = self.draw_text_block(solution_text, MARGIN, y_pos, 
                                     self.width - 2*MARGIN, 15, 
                                     "Helvetica", COLOR_TEXT_PRIMARY)
        
        y_pos -= 1.1*inch
        
        # Architecture components
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 20)
        self.c.drawString(MARGIN, y_pos, "Architecture Components")
        
        y_pos -= 0.55*inch
        
        components = [
            "Prometheus: 15s scrape for high-fidelity resource and container metrics",
            "Grafana: Real-time dashboards, alert rules, and trend analysis",
            "Node Exporter: Host CPU, memory, disk, network, interrupts, load",
            "cAdvisor: Per-container CPU/mem, I/O, network for model/agent services",
            "Nginx + Let's Encrypt: Secure access with TLS termination"
        ]
        
        y_pos = self.draw_bullet_points(components, MARGIN, y_pos, 
                                         self.width - 2*MARGIN, 14)
        
        self.draw_footer(3, 8)
    
    # PAGE 4: Technical Details
    def page_technical(self):
        self.draw_background()
        
        self.draw_title("Technical Foundation", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.3*inch
        
        # Infrastructure specs
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 20)
        self.c.drawString(MARGIN, y_pos, "Infrastructure")
        
        y_pos -= 0.5*inch
        
        specs = [
            "Proxmox host: Intel i7-6700 (8 cores), 62GB RAM",
            "Storage: ZFS on NVMe mirror (low-latency I/O)",
            "Metrics: 200-hour retention at 15s granularity",
            "Dashboards: sub-second query performance",
            "SLO: 99.9% availability"
        ]
        
        y_pos = self.draw_bullet_points(specs, MARGIN, y_pos, 
                                         self.width - 2*MARGIN, 14)
        
        y_pos -= 0.8*inch
        
        # Monitoring capabilities
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 20)
        self.c.drawString(MARGIN, y_pos, "Monitoring Capabilities")
        
        y_pos -= 0.5*inch
        
        capabilities = [
            "Host + container CPU load, throttling, and saturation",
            "Memory pressure, cache hit ratios, and OOM early signals",
            "Disk IOPS/throughput and latency under inference load",
            "Network throughput and egress limits under agent fan-out",
            "Process counts, interrupts, and system health baselines"
        ]
        
        y_pos = self.draw_bullet_points(capabilities, MARGIN, y_pos, 
                                         self.width - 2*MARGIN, 14)
        
        self.draw_footer(4, 8)
    
    # PAGE 5: Key Metrics
    def page_metrics(self):
        self.draw_background()
        self.draw_title("Key Metrics for Optimization", self.height - 1.25*inch, 40)
        # Add extra space below title/accent line
        y_pos = self.height - 2.55*inch

        # Metric cards grid (no screenshots)
        metric_width = 2.8*inch
        spacing = 0.4*inch
        x_start = (self.width - (2 * metric_width + spacing)) / 2

        # Top row
        self.draw_metric_box("64+", "Metric Series", x_start, y_pos, metric_width)
        self.draw_metric_box("15s", "Scrape Interval", x_start + metric_width + spacing, y_pos, metric_width)

        y_pos -= 1.2*inch

        # Bottom row
        self.draw_metric_box("200h", "Retention", x_start, y_pos, metric_width)
        self.draw_metric_box("99.9%", "SLO Uptime", x_start + metric_width + spacing, y_pos, metric_width)

        # Insights card - increased height to fit all bullet points
        y_pos -= 1.6*inch
        card_x = MARGIN
        card_w = self.width - 2*MARGIN
        card_h = 2.8*inch  # Increased from 2.2*inch to accommodate all 5 bullets
        self.draw_card(card_x, y_pos, card_w, card_h, radius=12, with_border=True, accent_top=True)

        # Card content
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 18)
        self.c.drawString(MARGIN + 0.45*inch, y_pos - 0.45*inch, "Observable Metrics")

        y_text = y_pos - 0.95*inch
        insights = [
            "p95/p99 latency tracking for model inference endpoints",
            "Tokens per second throughput measurement",
            "Container CPU throttling and memory pressure detection",
            "Disk I/O saturation under concurrent model loads",
            "Network bandwidth utilization for agent orchestration",
        ]

        _ = self.draw_bullet_points(
            insights, MARGIN + 0.45*inch, y_text, self.width - 2*MARGIN - 0.9*inch, 13  # Slightly smaller font
        )

        self.draw_footer(5, 8)
    
    # PAGE 6: Business Impact
    def page_impact(self):
        self.draw_background()
        
        self.draw_title("Optimization Impact", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.1*inch
        
        # Impact metrics
        impacts = [
            ("Latency -35%", "Reduced p95 inference time via CPU/memory tuning and I/O fixes"),
            ("Throughput +40%", "Higher tokens/s by eliminating container CPU throttling"),
            ("Stability +Reliability", "Zero unplanned outages across 30 days"),
            ("Capacity Forecasting", "Data-driven sizing for Proxmox VMs and storage")
        ]
        
        for title, description in impacts:
            # Title box
            self.c.setFillColor(colors.HexColor('#1a1f2e'))
            self.c.roundRect(MARGIN, y_pos - 0.1*inch, 
                           self.width - 2*MARGIN, 0.7*inch, 
                           8, fill=True, stroke=False)
            
            # Title
            self.c.setFillColor(COLOR_ACCENT)
            self.c.setFont("Helvetica-Bold", 18)
            self.c.drawString(MARGIN + 0.2*inch, y_pos + 0.35*inch, title)
            
            # Description
            self.c.setFillColor(COLOR_TEXT_PRIMARY)
            self.c.setFont("Helvetica", 14)
            self.c.drawString(MARGIN + 0.2*inch, y_pos + 0.05*inch, description)
            
            y_pos -= 1.1*inch
        
        self.draw_footer(6, 8)
    
    # PAGE 7: Technology Stack
    def page_tech_stack(self):
        self.draw_background()
        
        self.draw_title("Technology Stack", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.3*inch
        
        tech_categories = [
            ("Monitoring", ["Prometheus", "Grafana", "Node Exporter", "cAdvisor"]),
            ("Model & UI", ["Ollama", "OpenWebUI"]),
            ("Infrastructure", ["Docker", "Proxmox", "ZFS", "NVMe"]),
            ("Security", ["Nginx", "Let's Encrypt", "SSL/TLS"]),
            ("Database", ["PostgreSQL", "Time-Series Storage"])
        ]
        
        for category, technologies in tech_categories:
            # Category title
            self.c.setFillColor(COLOR_ACCENT)
            self.c.setFont("Helvetica-Bold", 18)
            self.c.drawString(MARGIN, y_pos, category)
            
            # Technologies
            self.c.setFillColor(COLOR_TEXT_PRIMARY)
            self.c.setFont("Helvetica", 14)
            tech_text = " • ".join(technologies)
            self.c.drawString(MARGIN + 0.2*inch, y_pos - 0.3*inch, tech_text)
            
            y_pos -= 0.85*inch
        
        y_pos -= 0.3*inch
        
        # Additional context (no image to avoid irrelevant screenshots)
        self.c.setFillColor(colors.HexColor('#1a1f2e'))
        self.c.roundRect(MARGIN, y_pos - 1.2*inch, self.width - 2*MARGIN, 1.1*inch, 10, fill=True, stroke=False)
        
        context = (
            "Production-grade deployment with enterprise observability, secure access, and scalable architecture "
            "for AI workloads. Comprehensive monitoring across host and containerized services enables "
            "data-driven optimization of model inference and agent orchestration on Proxmox infrastructure."
        )
        
        self.draw_text_block(context, MARGIN + 0.3*inch, y_pos - 0.4*inch, 
                           self.width - 2*MARGIN - 0.6*inch, 14, 
                           "Helvetica", COLOR_TEXT_SECONDARY)
        
        self.draw_footer(7, 8)
    
    # PAGE 8: Conclusion
    def page_conclusion(self):
        self.draw_background()
        
        self.draw_title("Key Takeaways", self.height - 1.3*inch, 40)
        
        y_pos = self.height - 2.3*inch
        
        takeaways = [
            "Observability drives optimization: measure p95/p99 latency, tokens/s, and saturation",
            "Container + host visibility prevents blind spots in agent orchestration",
            "Predictable performance on Proxmox via data-driven capacity planning",
            "Secure, self-hosted control with enterprise-grade reliability"
        ]
        
        y_pos = self.draw_bullet_points(takeaways, MARGIN, y_pos, 
                                         self.width - 2*MARGIN, 15)
        
        y_pos -= 1.2*inch
        
        # Call to action box
        self.c.setFillColor(colors.HexColor('#1a2b3a'))
        self.c.setStrokeColor(COLOR_ACCENT)
        self.c.setLineWidth(2)
        self.c.roundRect(MARGIN, y_pos - 1.3*inch, 
                          self.width - 2*MARGIN, 1.2*inch, 
                          10, fill=True, stroke=True)
        
        self.c.setFillColor(COLOR_TEXT_PRIMARY)
        self.c.setFont("Helvetica-Bold", 18)
        self.c.drawCentredString(self.width/2, y_pos - 0.5*inch, 
                                 "Questions about implementation?")
        
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", 14)
        self.c.drawCentredString(self.width/2, y_pos - 0.8*inch, 
                                 "Connect with me to discuss architecture and best practices")
        
        # Contact info
        y_pos -= 2.2*inch
        self.c.setFillColor(COLOR_ACCENT)
        self.c.setFont("Helvetica-Bold", 16)
        self.c.drawCentredString(self.width/2, y_pos, "Simon Renauld")
        
        self.c.setFillColor(COLOR_TEXT_SECONDARY)
        self.c.setFont("Helvetica", 14)
        self.c.drawCentredString(self.width/2, y_pos - 0.3*inch, 
                                 "simondatalab.de")
        
        self.draw_footer(8, 8)
    
    def generate(self):
        """Generate the complete carousel"""
        # Screenshot capture disabled to avoid hanging
        # Images will show placeholders if files don't exist

        pages = [
            self.page_cover,
            self.page_challenge,
            self.page_solution,
            self.page_technical,
            self.page_metrics,
            self.page_impact,
            self.page_tech_stack,
            self.page_conclusion
        ]
        
        for page in pages:
            self.add_page(page)
        
        self.c.save()
        print(f"LinkedIn carousel PDF generated: {self.output_path}")

if __name__ == "__main__":
    output_file = "/home/simon/Learning-Management-System-Academy/deploy/prometheus/Infrastructure_Monitoring_LinkedIn_Carousel.pdf"
    
    carousel = LinkedInCarousel(output_file)
    carousel.generate()
    
    print(f"\nPDF created successfully!")
    print(f"Location: {output_file}")
    print(f"\nOptimized for LinkedIn carousel (1080x1080px)")
    print(f"Professional style matching simondatalab.de")
    print(f"8 pages covering: Challenge → Solution → Impact → Tech Stack")
