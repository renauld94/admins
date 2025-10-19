#!/usr/bin/env python3
"""
Creative Animation Studio 🎨
Advanced video effects and artistic animations
"""

import argparse
import os
import sys
from pathlib import Path
import numpy as np

try:
    from moviepy.editor import (VideoFileClip, concatenate_videoclips, 
                               TextClip, CompositeVideoClip, ColorClip)
    from moviepy.video.fx import all as vfx
    from PIL import Image, ImageEnhance, ImageFilter
    import cv2
except ImportError:
    print("🎨 Installing creative tools...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", 
                          "moviepy", "pillow", "opencv-python", "numpy"])
    from moviepy.editor import (VideoFileClip, concatenate_videoclips,
                               TextClip, CompositeVideoClip, ColorClip)
    from moviepy.video.fx import all as vfx
    from PIL import Image, ImageEnhance, ImageFilter
    import cv2


class CreativeAnimationStudio:
    """Main class for creating artistic animations"""
    
    def __init__(self, video_path: str):
        self.video_path = Path(video_path)
        if not self.video_path.exists():
            raise FileNotFoundError(f"Video not found: {video_path}")
        
        print(f"🎬 Loading: {self.video_path.name}")
        self.clip = VideoFileClip(str(self.video_path))
        print(f"   Duration: {self.clip.duration:.2f}s | Size: {self.clip.size} | FPS: {self.clip.fps}")
    
    def apply_glitch_effect(self, intensity=0.3):
        """Digital glitch effect"""
        print("⚡ Applying glitch effect...")
        
        def glitch_frame(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            if np.random.random() < intensity:
                # Random channel shifts
                shift = np.random.randint(-20, 20)
                frame[:, :, 0] = np.roll(frame[:, :, 0], shift, axis=1)
                frame[:, :, 2] = np.roll(frame[:, :, 2], -shift, axis=1)
            return frame
        
        return self.clip.fl(glitch_frame)
    
    def apply_vaporwave_aesthetic(self):
        """Vaporwave/retrowave color grading"""
        print("🌊 Creating vaporwave aesthetic...")
        
        def vaporwave_frame(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            # Enhance cyan and magenta
            frame[:, :, 0] = np.clip(frame[:, :, 0] * 0.8 + 80, 0, 255)  # Boost cyan
            frame[:, :, 1] = np.clip(frame[:, :, 1] * 0.9, 0, 255)
            frame[:, :, 2] = np.clip(frame[:, :, 2] * 1.2 + 40, 0, 255)  # Boost magenta
            return frame.astype('uint8')
        
        return self.clip.fl(vaporwave_frame)
    
    def apply_pixel_art(self, pixel_size=8):
        """Pixelate effect"""
        print(f"🎮 Pixelating (size: {pixel_size})...")
        
        def pixelate(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            h, w = frame.shape[:2]
            
            # Downscale
            small = cv2.resize(frame, (w // pixel_size, h // pixel_size), 
                             interpolation=cv2.INTER_LINEAR)
            # Upscale back
            pixelated = cv2.resize(small, (w, h), interpolation=cv2.INTER_NEAREST)
            return pixelated
        
        return self.clip.fl(pixelate)
    
    def apply_matrix_effect(self):
        """Matrix digital rain overlay"""
        print("💚 Adding Matrix effect...")
        
        def matrix_overlay(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            h, w = frame.shape[:2]
            
            # Create green tint
            matrix_frame = frame.copy()
            matrix_frame[:, :, 1] = np.clip(matrix_frame[:, :, 1] * 1.5, 0, 255)
            matrix_frame[:, :, 0] = matrix_frame[:, :, 0] * 0.3
            matrix_frame[:, :, 2] = matrix_frame[:, :, 2] * 0.3
            
            # Add random "rain" effect
            rain = np.random.randint(0, 100, size=(h, w))
            mask = rain > 95
            matrix_frame[mask] = [0, 255, 0]
            
            return matrix_frame.astype('uint8')
        
        return self.clip.fl(matrix_overlay)
    
    def apply_chromatic_aberration(self, shift=5):
        """RGB channel separation"""
        print("🌈 Applying chromatic aberration...")
        
        def chromatic(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            shifted = frame.copy()
            shifted[:, :, 0] = np.roll(frame[:, :, 0], -shift, axis=1)
            shifted[:, :, 2] = np.roll(frame[:, :, 2], shift, axis=1)
            return shifted
        
        return self.clip.fl(chromatic)
    
    def apply_neon_glow(self):
        """Neon glow effect"""
        print("✨ Adding neon glow...")
        
        def neon(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            # Increase saturation and brightness
            hsv = cv2.cvtColor(frame, cv2.COLOR_RGB2HSV)
            hsv[:, :, 1] = np.clip(hsv[:, :, 1] * 1.5, 0, 255)
            hsv[:, :, 2] = np.clip(hsv[:, :, 2] * 1.3, 0, 255)
            glowing = cv2.cvtColor(hsv, cv2.COLOR_HSV2RGB)
            
            # Add blur overlay
            blurred = cv2.GaussianBlur(glowing, (21, 21), 0)
            result = cv2.addWeighted(glowing, 0.7, blurred, 0.3, 0)
            return result
        
        return self.clip.fl(neon)
    
    def apply_cyberpunk_style(self):
        """Full cyberpunk treatment"""
        print("🤖 Creating cyberpunk style...")
        clip = self.clip
        clip = self.apply_chromatic_aberration(shift=3)
        clip = self.apply_neon_glow()
        clip = self.apply_glitch_effect(intensity=0.15)
        return clip
    
    def apply_film_noir(self):
        """Black and white with high contrast"""
        print("🎞️ Applying film noir...")
        
        def noir(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            # Convert to grayscale
            gray = cv2.cvtColor(frame, cv2.COLOR_RGB2GRAY)
            # High contrast
            gray = cv2.convertScaleAbs(gray, alpha=1.5, beta=-50)
            # Add grain
            noise = np.random.normal(0, 10, gray.shape)
            grainy = np.clip(gray + noise, 0, 255).astype('uint8')
            # Convert back to RGB
            return cv2.cvtColor(grainy, cv2.COLOR_GRAY2RGB)
        
        return self.clip.fl(noir)
    
    def apply_retrowave(self):
        """80s retrowave aesthetic"""
        print("🌅 Creating retrowave...")
        
        def retrowave(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            # Purple/pink/blue gradient overlay
            h, w = frame.shape[:2]
            gradient = np.zeros_like(frame)
            
            for i in range(h):
                ratio = i / h
                # Purple to pink to blue
                gradient[i, :, 0] = min(255, int(150 * (1 - ratio)))  # R
                gradient[i, :, 1] = min(255, int(50 + 100 * ratio))    # G
                gradient[i, :, 2] = min(255, int(150 * ratio + 100))   # B (fixed overflow)
            
            # Blend with original
            result = cv2.addWeighted(frame, 0.6, gradient, 0.4, 0)
            return result.astype('uint8')
        
        return self.clip.fl(retrowave)
    
    def apply_kaleidoscope(self, segments=6):
        """Kaleidoscope mirror effect"""
        print(f"🔮 Creating kaleidoscope (segments: {segments})...")
        
        def kaleidoscope(get_frame, t):
            frame = get_frame(t).copy()  # Make writable copy
            h, w = frame.shape[:2]
            center = (w // 2, h // 2)
            
            # Create kaleidoscope effect
            angle = 360 / segments
            result = frame.copy()
            
            for i in range(segments):
                rotation = cv2.getRotationMatrix2D(center, i * angle, 1.0)
                rotated = cv2.warpAffine(frame, rotation, (w, h))
                result = cv2.addWeighted(result, 0.5, rotated, 0.5, 0)
            
            return result.astype('uint8')
        
        return self.clip.fl(kaleidoscope)
    
    def apply_time_effects(self, speed=1.0, reverse=False, bounce=False):
        """Time manipulation effects"""
        clip = self.clip
        
        if reverse:
            print("⏪ Reversing time...")
            clip = clip.fx(vfx.time_mirror)
        
        if speed != 1.0:
            print(f"⏱️ Adjusting speed: {speed}x...")
            clip = clip.fx(vfx.speedx, speed)
        
        if bounce:
            print("🔁 Creating bounce effect...")
            reversed_clip = clip.fx(vfx.time_mirror)
            clip = concatenate_videoclips([clip, reversed_clip])
        
        return clip
    
    def add_text_overlay(self, text, position='bottom', style='cyberpunk'):
        """Add stylized text overlay"""
        print(f"📝 Adding text: '{text}'")
        
        styles = {
            'cyberpunk': {
                'fontsize': 60,
                'color': 'cyan',
                'font': 'Arial-Bold',
                'stroke_color': 'magenta',
                'stroke_width': 2
            },
            'retro': {
                'fontsize': 70,
                'color': 'yellow',
                'font': 'Impact',
                'stroke_color': 'purple',
                'stroke_width': 3
            },
            'minimal': {
                'fontsize': 40,
                'color': 'white',
                'font': 'Arial',
                'stroke_color': 'black',
                'stroke_width': 1
            }
        }
        
        style_config = styles.get(style, styles['cyberpunk'])
        
        try:
            txt_clip = TextClip(
                text,
                fontsize=style_config['fontsize'],
                color=style_config['color'],
                font=style_config.get('font', 'Arial'),
                stroke_color=style_config.get('stroke_color'),
                stroke_width=style_config.get('stroke_width', 0)
            ).set_duration(self.clip.duration)
            
            # Position
            if position == 'bottom':
                txt_clip = txt_clip.set_position(('center', 'bottom'))
            elif position == 'top':
                txt_clip = txt_clip.set_position(('center', 'top'))
            else:
                txt_clip = txt_clip.set_position('center')
            
            return CompositeVideoClip([self.clip, txt_clip])
        except Exception as e:
            print(f"⚠️ Text overlay failed: {e}")
            return self.clip
    
    def create_masterpiece(self, output_path, style='cyberpunk', fps=15, 
                          resize=1.0, add_text=None, segment=(None, None)):
        """Create the final artistic animation"""
        print("\n🎨 ═══════════════════════════════════════")
        print("   CREATIVE ANIMATION STUDIO")
        print("   ═══════════════════════════════════════")
        
        clip = self.clip
        
        # Apply time segment
        start, end = segment
        if start is not None or end is not None:
            start = start or 0
            end = end or clip.duration
            print(f"✂️ Cutting segment: {start}s - {end}s")
            clip = clip.subclip(start, end)
            self.clip = clip
        
        # Apply creative style
        styles = {
            'cyberpunk': self.apply_cyberpunk_style,
            'vaporwave': self.apply_vaporwave_aesthetic,
            'matrix': self.apply_matrix_effect,
            'retrowave': self.apply_retrowave,
            'noir': self.apply_film_noir,
            'glitch': lambda: self.apply_glitch_effect(0.4),
            'neon': self.apply_neon_glow,
            'pixel': lambda: self.apply_pixel_art(6),
            'kaleidoscope': lambda: self.apply_kaleidoscope(8),
            'chromatic': lambda: self.apply_chromatic_aberration(8)
        }
        
        if style in styles:
            print(f"\n🎭 Applying style: {style.upper()}")
            self.clip = styles[style]()
        
        # Add text overlay if requested
        if add_text:
            self.clip = self.add_text_overlay(add_text, style=style)
        
        # Resize
        if resize != 1.0:
            print(f"📐 Resizing: {resize * 100}%")
            new_size = (int(clip.size[0] * resize), int(clip.size[1] * resize))
            self.clip = self.clip.resize(new_size)
        
        # Export
        output_path = Path(output_path)
        print(f"\n💾 Rendering to: {output_path.name}")
        print("   This may take a few minutes...")
        
        if output_path.suffix.lower() == '.gif':
            self.clip.write_gif(str(output_path), fps=fps, opt='optimizeplus')
        else:
            self.clip.write_videofile(
                str(output_path),
                fps=fps,
                codec='libx264',
                audio_codec='aac' if self.clip.audio else None
            )
        
        file_size = os.path.getsize(output_path) / (1024 * 1024)
        print("\n✅ ═══════════════════════════════════════")
        print(f"   ANIMATION COMPLETE!")
        print(f"   File: {output_path}")
        print(f"   Size: {file_size:.2f} MB")
        print("   ═══════════════════════════════════════\n")
        
        self.clip.close()
        return output_path


def main():
    parser = argparse.ArgumentParser(
        description='🎨 Creative Animation Studio - Turn videos into art',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
🎭 AVAILABLE STYLES:
  cyberpunk    - Neon glitch aesthetic with chromatic aberration
  vaporwave    - Pastel cyan/magenta retro vibes
  matrix       - Green digital rain effect
  retrowave    - 80s sunset gradient
  noir         - High contrast black and white
  glitch       - Digital corruption effect
  neon         - Glowing saturated colors
  pixel        - Retro pixel art style
  kaleidoscope - Psychedelic mirror effect
  chromatic    - Heavy RGB separation

✨ CREATIVE EXAMPLES:

  # Cyberpunk masterpiece from 5-8 seconds
  python creative_animation_studio.py video.mp4 -s cyberpunk --start 5 --end 8 -o cyber.gif
  
  # Vaporwave aesthetic with text
  python creative_animation_studio.py video.mp4 -s vaporwave --text "ÆSTHETIC" -o wave.gif
  
  # Matrix effect full video
  python creative_animation_studio.py video.mp4 -s matrix --fps 20 -o matrix.mp4
  
  # Retrowave with smaller size
  python creative_animation_studio.py video.mp4 -s retrowave --resize 0.5 -o retro.gif
  
  # Film noir artistic piece
  python creative_animation_studio.py video.mp4 -s noir --start 5 --end 8 --fps 12
  
  # Glitch art
  python creative_animation_studio.py video.mp4 -s glitch --text "ERROR 404" -o glitch.gif
        """
    )
    
    parser.add_argument('input', help='Input MP4 video file')
    parser.add_argument('-s', '--style', 
                       choices=['cyberpunk', 'vaporwave', 'matrix', 'retrowave', 
                               'noir', 'glitch', 'neon', 'pixel', 'kaleidoscope', 'chromatic'],
                       default='cyberpunk',
                       help='Creative style to apply (default: cyberpunk)')
    parser.add_argument('-o', '--output', help='Output file path (.gif or .mp4)')
    parser.add_argument('--fps', type=int, default=15, help='Frames per second (default: 15)')
    parser.add_argument('--resize', type=float, default=1.0, 
                       help='Resize factor (0.5 = half size, default: 1.0)')
    parser.add_argument('--start', type=float, help='Start time in seconds')
    parser.add_argument('--end', type=float, help='End time in seconds')
    parser.add_argument('--text', help='Add text overlay')
    
    args = parser.parse_args()
    
    try:
        # Generate output filename if not provided
        if args.output is None:
            input_path = Path(args.input)
            args.output = input_path.parent / f"{input_path.stem}_{args.style}.gif"
        
        # Create the masterpiece
        studio = CreativeAnimationStudio(args.input)
        studio.create_masterpiece(
            output_path=args.output,
            style=args.style,
            fps=args.fps,
            resize=args.resize,
            add_text=args.text,
            segment=(args.start, args.end)
        )
        
    except KeyboardInterrupt:
        print("\n⚠️ Cancelled by user")
        return 1
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
