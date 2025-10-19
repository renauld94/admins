#!/usr/bin/env python3
"""
🎬 Quick Animation Creator
Simply drag & drop your video and get instant artistic animations!
"""

import sys
from pathlib import Path

BANNER = """
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║         🎨 CREATIVE ANIMATION STUDIO 🎨              ║
║                                                       ║
║           Transform Videos into Art                   ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"""

STYLES_INFO = """
🎭 AVAILABLE STYLES:

1. Cyberpunk    - ⚡ Neon glitch with chromatic aberration
2. Vaporwave    - 🌊 Pastel aesthetic vibes
3. Matrix       - 💚 Digital rain effect
4. Retrowave    - 🌅 80s sunset gradient
5. Noir         - 🎞️  High contrast black & white
6. Glitch       - 📺 Digital corruption
7. Neon         - ✨ Saturated glowing colors
8. Pixel        - 🎮 Retro 8-bit style
9. Kaleidoscope - 🔮 Psychedelic mirrors
10. Chromatic   - 🌈 RGB separation
11. ALL         - 🎨 Create all styles!
"""


def get_video_path():
    """Get video path from user"""
    if len(sys.argv) > 1:
        return sys.argv[1]
    
    # Interactive mode
    print("\n📹 Enter the path to your video file:")
    print("   (or drag & drop the file here)")
    print("   (or type 'list' to see available videos)")
    
    while True:
        video_path = input("\n> ").strip().strip("'\"")
        
        if video_path.lower() == 'list':
            print("\n📁 Available MP4 files:")
            import subprocess
            result = subprocess.run(
                ["find", ".", "-name", "*.mp4", "-type", "f"],
                capture_output=True,
                text=True,
                cwd="/home/simon/Learning-Management-System-Academy"
            )
            videos = [v for v in result.stdout.strip().split('\n') if v and 'postgres-data' not in v]
            for i, v in enumerate(videos[:10], 1):
                print(f"   {i}. {v}")
            print("\nEnter the path or number:")
            continue
        
        # Check if it's a number (selecting from list)
        if video_path.isdigit():
            try:
                import subprocess
                result = subprocess.run(
                    ["find", ".", "-name", "*.mp4", "-type", "f"],
                    capture_output=True,
                    text=True,
                    cwd="/home/simon/Learning-Management-System-Academy"
                )
                videos = [v for v in result.stdout.strip().split('\n') if v and 'postgres-data' not in v]
                idx = int(video_path) - 1
                if 0 <= idx < len(videos):
                    return videos[idx]
                else:
                    print(f"   ❌ Invalid selection. Please choose 1-{len(videos)}")
                    continue
            except:
                pass
        
        return video_path


def get_time_segment():
    """Get start and end times"""
    print("\n⏱️  Time Segment:")
    print("   (press Enter to use full video)")
    
    while True:
        start_input = input("   Start time (seconds): ").strip()
        if not start_input:
            start = None
            break
        try:
            start = float(start_input)
            break
        except ValueError:
            print(f"   ❌ Invalid input '{start_input}'. Please enter a number or press Enter to skip.")
    
    while True:
        end_input = input("   End time (seconds): ").strip()
        if not end_input:
            end = None
            break
        try:
            end = float(end_input)
            break
        except ValueError:
            print(f"   ❌ Invalid input '{end_input}'. Please enter a number or press Enter to skip.")
    
    return start, end


def get_style_choice():
    """Get style selection"""
    print(STYLES_INFO)
    
    choice = input("Select style (1-11) or name: ").strip().lower()
    
    style_map = {
        '1': 'cyberpunk', 'cyberpunk': 'cyberpunk',
        '2': 'vaporwave', 'vaporwave': 'vaporwave',
        '3': 'matrix', 'matrix': 'matrix',
        '4': 'retrowave', 'retrowave': 'retrowave',
        '5': 'noir', 'noir': 'noir',
        '6': 'glitch', 'glitch': 'glitch',
        '7': 'neon', 'neon': 'neon',
        '8': 'pixel', 'pixel': 'pixel',
        '9': 'kaleidoscope', 'kaleidoscope': 'kaleidoscope',
        '10': 'chromatic', 'chromatic': 'chromatic',
        '11': 'all', 'all': 'all'
    }
    
    return style_map.get(choice, 'cyberpunk')


def get_text_overlay():
    """Get optional text overlay"""
    print("\n📝 Text Overlay (optional):")
    text = input("   Text to add (or press Enter to skip): ").strip()
    return text if text else None


def main():
    print(BANNER)
    
    # Get parameters
    video_path = get_video_path()
    
    if not Path(video_path).exists():
        print(f"\n❌ Error: Video file not found: {video_path}")
        return 1
    
    start, end = get_time_segment()
    style = get_style_choice()
    text = get_text_overlay()
    
    # Summary
    print("\n" + "═" * 55)
    print("📋 CONFIGURATION SUMMARY")
    print("═" * 55)
    print(f"📹 Video: {Path(video_path).name}")
    print(f"⏱️  Segment: {start or 'start'} → {end or 'end'} seconds")
    print(f"🎭 Style: {style}")
    print(f"📝 Text: {text or 'None'}")
    print("═" * 55)
    
    confirm = input("\n🚀 Create animation? [Y/n]: ").strip().lower()
    if confirm and confirm != 'y':
        print("❌ Cancelled")
        return 0
    
    # Build command
    import subprocess
    
    if style == 'all':
        # Batch create all styles
        cmd = [
            sys.executable,
            "tools/batch_animation_creator.py",
            video_path,
            "--output-dir", "./animations"
        ]
        if start is not None:
            cmd.extend(["--start", str(start)])
        if end is not None:
            cmd.extend(["--end", str(end)])
        if text:
            cmd.extend(["--text", text])
    else:
        # Single style
        output_name = f"{Path(video_path).stem}_{style}.gif"
        cmd = [
            sys.executable,
            "tools/creative_animation_studio.py",
            video_path,
            "-s", style,
            "-o", output_name
        ]
        if start is not None:
            cmd.extend(["--start", str(start)])
        if end is not None:
            cmd.extend(["--end", str(end)])
        if text:
            cmd.extend(["--text", text])
    
    print("\n🎬 Creating your masterpiece...\n")
    
    try:
        subprocess.run(cmd, check=True)
        print("\n✨ Done! Your animation is ready! ✨")
        return 0
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Error creating animation: {e}")
        return 1
    except KeyboardInterrupt:
        print("\n⚠️  Cancelled by user")
        return 1


if __name__ == '__main__':
    sys.exit(main())
