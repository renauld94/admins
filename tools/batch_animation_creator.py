#!/usr/bin/env python3
"""
Batch Animation Creator 🚀
Create multiple artistic variations of your video automatically
"""

import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed


def create_animation(input_video, style, output_dir, start=None, end=None, text=None):
    """Create a single animation with given style"""
    output_path = output_dir / f"{Path(input_video).stem}_{style}.gif"
    
    cmd = [
        sys.executable,
        "tools/creative_animation_studio.py",
        str(input_video),
        "-s", style,
        "-o", str(output_path),
        "--fps", "15",
        "--resize", "0.7"  # Smaller for batch processing
    ]
    
    if start is not None:
        cmd.extend(["--start", str(start)])
    if end is not None:
        cmd.extend(["--end", str(end)])
    if text:
        cmd.extend(["--text", text])
    
    try:
        print(f"\n🎬 Creating {style} animation...")
        subprocess.run(cmd, check=True)
        return style, output_path, True
    except Exception as e:
        print(f"❌ Failed to create {style}: {e}")
        return style, None, False


def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description='🚀 Batch create multiple artistic animations',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('input', help='Input MP4 video file')
    parser.add_argument('-o', '--output-dir', help='Output directory (default: ./animations)')
    parser.add_argument('--start', type=float, help='Start time in seconds')
    parser.add_argument('--end', type=float, help='End time in seconds')
    parser.add_argument('--text', help='Text overlay for all animations')
    parser.add_argument('--parallel', type=int, default=2, 
                       help='Number of parallel processes (default: 2)')
    parser.add_argument('--styles', nargs='+',
                       help='Specific styles to create (default: all)')
    
    args = parser.parse_args()
    
    # Setup
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"❌ Error: Video not found: {args.input}")
        return 1
    
    output_dir = Path(args.output_dir) if args.output_dir else Path("./animations")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Styles to create
    all_styles = ['cyberpunk', 'vaporwave', 'matrix', 'retrowave', 'noir', 
                  'glitch', 'neon', 'pixel', 'kaleidoscope', 'chromatic']
    
    styles = args.styles if args.styles else all_styles
    
    print("=" * 60)
    print("🎨 BATCH ANIMATION CREATOR")
    print("=" * 60)
    print(f"📹 Input: {input_path.name}")
    print(f"📁 Output: {output_dir}")
    print(f"🎭 Styles: {', '.join(styles)}")
    print(f"⚡ Parallel: {args.parallel}")
    print("=" * 60)
    
    # Create animations
    results = []
    with ThreadPoolExecutor(max_workers=args.parallel) as executor:
        futures = {
            executor.submit(
                create_animation, 
                input_path, 
                style, 
                output_dir,
                args.start,
                args.end,
                args.text
            ): style for style in styles
        }
        
        for future in as_completed(futures):
            style, output, success = future.result()
            results.append((style, output, success))
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 BATCH CREATION COMPLETE!")
    print("=" * 60)
    
    successful = [r for r in results if r[2]]
    failed = [r for r in results if not r[2]]
    
    print(f"✅ Successful: {len(successful)}/{len(results)}")
    for style, output, _ in successful:
        print(f"   • {style}: {output.name}")
    
    if failed:
        print(f"\n❌ Failed: {len(failed)}")
        for style, _, _ in failed:
            print(f"   • {style}")
    
    print("=" * 60)
    return 0 if not failed else 1


if __name__ == '__main__':
    sys.exit(main())
