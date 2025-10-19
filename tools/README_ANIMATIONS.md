# 🎨 Creative Animation Studio

Transform your videos into stunning artistic animations with cyberpunk, vaporwave, and retro effects!

## 🚀 Quick Start

### Single Animation (5-8 second segment)

```bash
# Cyberpunk style
python tools/creative_animation_studio.py your_video.mp4 -s cyberpunk --start 5 --end 8

# Vaporwave aesthetic
python tools/creative_animation_studio.py your_video.mp4 -s vaporwave --start 5 --end 8 --text "A E S T H E T I C"

# Matrix effect
python tools/creative_animation_studio.py your_video.mp4 -s matrix --start 5 --end 8

# Retrowave sunset
python tools/creative_animation_studio.py your_video.mp4 -s retrowave --start 5 --end 8

# Film noir
python tools/creative_animation_studio.py your_video.mp4 -s noir --start 5 --end 8
```

### Batch Create All Styles

```bash
# Create ALL 10 styles at once!
python tools/batch_animation_creator.py your_video.mp4 --start 5 --end 8 --output-dir ./my_animations

# Create specific styles only
python tools/batch_animation_creator.py your_video.mp4 --start 5 --end 8 --styles cyberpunk vaporwave matrix
```

## 🎭 Available Styles

| Style | Description | Perfect For |
|-------|-------------|-------------|
| **cyberpunk** | Neon glitch with chromatic aberration | Tech, futuristic content |
| **vaporwave** | Pastel cyan/magenta aesthetic | Retro, dreamy vibes |
| **matrix** | Green digital rain effect | Code, hacker themes |
| **retrowave** | 80s sunset gradient | Nostalgic, synth content |
| **noir** | High contrast black & white | Dramatic, artistic |
| **glitch** | Digital corruption | Error aesthetic, chaos |
| **neon** | Saturated glowing colors | Night scenes, vibrant |
| **pixel** | Retro pixel art style | Gaming, 8-bit vibes |
| **kaleidoscope** | Psychedelic mirror effect | Trippy, abstract |
| **chromatic** | Heavy RGB separation | Artistic, avant-garde |

## 📋 Advanced Options

### Custom Output Format

```bash
# Save as MP4 instead of GIF
python tools/creative_animation_studio.py video.mp4 -s cyberpunk -o output.mp4

# Custom FPS
python tools/creative_animation_studio.py video.mp4 -s vaporwave --fps 20

# Resize (0.5 = 50% size)
python tools/creative_animation_studio.py video.mp4 -s matrix --resize 0.5
```

### Add Text Overlay

```bash
# Cyberpunk style text
python tools/creative_animation_studio.py video.mp4 -s cyberpunk --text "CHAOS OF SAMHAIN"

# Retro style text
python tools/creative_animation_studio.py video.mp4 -s retrowave --text "1985"

# Glitch text
python tools/creative_animation_studio.py video.mp4 -s glitch --text "ERROR 404"
```

### Time Segments

```bash
# First 3 seconds
python tools/creative_animation_studio.py video.mp4 -s vaporwave --start 0 --end 3

# Middle section
python tools/creative_animation_studio.py video.mp4 -s cyberpunk --start 5 --end 8

# Last 5 seconds
python tools/creative_animation_studio.py video.mp4 -s matrix --end -5
```

## 🎬 Example Workflows

### Create a Social Media Collection

```bash
# Instagram Stories (vertical, 9:16)
python tools/creative_animation_studio.py video.mp4 -s vaporwave --start 5 --end 8 --text "VIBES"

# Twitter/X post (optimized size)
python tools/creative_animation_studio.py video.mp4 -s cyberpunk --start 5 --end 8 --resize 0.6

# LinkedIn carousel
python tools/batch_animation_creator.py video.mp4 --start 5 --end 8 --styles cyberpunk vaporwave noir
```

### Create an Artistic Portfolio

```bash
# Generate all styles for comparison
python tools/batch_animation_creator.py video.mp4 --start 5 --end 8 --output-dir portfolio_pieces

# High quality MP4 renders
python tools/creative_animation_studio.py video.mp4 -s cyberpunk --fps 30 -o portfolio_cyber.mp4
python tools/creative_animation_studio.py video.mp4 -s noir --fps 30 -o portfolio_noir.mp4
```

## 🔧 Technical Details

### Installed Dependencies
- moviepy (video processing)
- opencv-python (effects & filters)
- pillow (image manipulation)
- numpy (array operations)

### Output Formats
- `.gif` - Animated GIF (optimized)
- `.mp4` - H.264 video with AAC audio

### Performance Tips
- Lower `--fps` for smaller files (10-15 recommended for GIFs)
- Use `--resize 0.5` to reduce file size by ~75%
- Batch processing uses parallel workers (adjust with `--parallel`)

## 🎨 Creative Tips

1. **Cyberpunk**: Works great for tech/gaming content
2. **Vaporwave**: Perfect for aesthetic/chill vibes
3. **Matrix**: Ideal for coding/hacking themes
4. **Noir**: Best for dramatic scenes
5. **Glitch**: Creates chaotic, unstable feel
6. **Kaleidoscope**: Amazing for abstract art

## 📦 File Structure

```
tools/
├── creative_animation_studio.py  # Main creative engine
├── batch_animation_creator.py    # Batch processor
└── video_to_animation.py         # Basic converter
```

## 🆘 Troubleshooting

**"ModuleNotFoundError"**: The script auto-installs dependencies on first run

**"Memory Error"**: Use `--resize 0.5` to reduce memory usage

**"Slow rendering"**: Lower FPS with `--fps 10` or use smaller segment

## 🌟 Examples Gallery

Based on your "Chaos of Samhain" theme, try:

```bash
# Cyberpunk chaos
python tools/creative_animation_studio.py video.mp4 -s cyberpunk --start 5 --end 8 --text "CHAOS OF SAMHAIN"

# Glitch apocalypse
python tools/creative_animation_studio.py video.mp4 -s glitch --start 5 --end 8 --text "SAMHAIN"

# Noir mystique
python tools/creative_animation_studio.py video.mp4 -s noir --start 5 --end 8

# Matrix digital world
python tools/creative_animation_studio.py video.mp4 -s matrix --start 5 --end 8
```

---

**Made with 🎨 by Creative Animation Studio**
