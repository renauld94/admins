#!/usr/bin/env python3
print("1. Starting imports...")

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
print("2. Basic imports done")

from reportlab.lib import colors
print("3. Colors imported")

from reportlab.platypus import Paragraph, Frame
print("4. Platypus imported")

from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
print("5. Styles imported")

from reportlab.lib.utils import ImageReader
print("6. ImageReader imported")

import os
import subprocess
from shutil import which
print("7. All imports complete")

print("8. Creating canvas...")
c = canvas.Canvas("/tmp/test.pdf", pagesize=(10*inch, 10*inch))
print("9. Canvas created")

print("10. Drawing text...")
c.drawString(100, 100, "Test")
print("11. Text drawn")

print("12. Saving...")
c.save()
print("13. DONE!")
