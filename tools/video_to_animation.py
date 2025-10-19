#!/usr/bin/env python3
"""
Video to Animation Converter
Creates animated GIFs or image sequences from MP4 videos
"""

import argparse
import os
import sys
from pathlib import Path

try:
    from moviepy.editor import VideoFileClip
    from PIL import Image
    import numpy as np
except ImportError:
    print("Required packages not found. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "moviepy", "pillow", "numpy"])
    from moviepy.editor import VideoFileClip
    from PIL import Image
    import numpy as np


def video_to_gif(input_video: str, output_path: str = None, fps: int = 10, 
                 resize_factor: float = 1.0, duration: tuple = None,
                 optimize: bool = True):
    """
    Convert MP4 video to animated GIF
    
    Args:
        input_video: Path to input MP4 file
        output_path: Path for output GIF (optional)
        fps: Frames per second for the GIF
        resize_factor: Scale factor for resizing (1.0 = original size, 0.5 = half size)
        duration: Tuple of (start_time, end_time) in seconds, None for full video
        optimize: Whether to optimize the GIF file size
    """
    video_path = Path(input_video)
    
    if not video_path.exists():
        raise FileNotFoundError(f"Video file not found: {input_video}")
    
    # Generate output path if not provided
    if output_path is None:
        output_path = video_path.with_suffix('.gif')
    
    print(f"Loading video: {input_video}")
    clip = VideoFileClip(str(video_path))
    
    # Get video info
    print(f"Video duration: {clip.duration:.2f} seconds")
    print(f"Video size: {clip.size}")
    print(f"Video FPS: {clip.fps}")
    
    # Apply duration if specified
    if duration:
        start, end = duration
        clip = clip.subclip(start, end)
        print(f"Using clip from {start}s to {end}s")
    
    # Resize if needed
    if resize_factor != 1.0:
        new_width = int(clip.size[0] * resize_factor)
        new_height = int(clip.size[1] * resize_factor)
        clip = clip.resize((new_width, new_height))
        print(f"Resized to: {new_width}x{new_height}")
    
    print(f"Creating GIF with {fps} FPS...")
    print(f"Output: {output_path}")
    
    # Write GIF
    clip.write_gif(
        str(output_path),
        fps=fps,
        opt='optimizeplus' if optimize else 'nq'
    )
    
    clip.close()
    
    file_size = os.path.getsize(output_path) / (1024 * 1024)  # MB
    print(f"✓ GIF created successfully!")
    print(f"File size: {file_size:.2f} MB")
    print(f"Saved to: {output_path}")
    
    return output_path


def video_to_frames(input_video: str, output_dir: str = None, 
                    frame_rate: int = None, format: str = 'png'):
    """
    Extract frames from video as image sequence
    
    Args:
        input_video: Path to input MP4 file
        output_dir: Directory to save frames
        frame_rate: Number of frames to extract per second (None = all frames)
        format: Image format (png, jpg, etc.)
    """
    video_path = Path(input_video)
    
    if not video_path.exists():
        raise FileNotFoundError(f"Video file not found: {input_video}")
    
    # Generate output directory if not provided
    if output_dir is None:
        output_dir = video_path.parent / f"{video_path.stem}_frames"
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Loading video: {input_video}")
    clip = VideoFileClip(str(video_path))
    
    print(f"Video duration: {clip.duration:.2f} seconds")
    print(f"Video FPS: {clip.fps}")
    
    # Calculate frame extraction rate
    if frame_rate:
        fps = frame_rate
    else:
        fps = clip.fps
    
    print(f"Extracting frames at {fps} FPS...")
    
    frame_count = 0
    for i, frame in enumerate(clip.iter_frames(fps=fps)):
        frame_path = output_dir / f"frame_{i:05d}.{format}"
        img = Image.fromarray(frame)
        img.save(frame_path)
        frame_count += 1
        
        if frame_count % 10 == 0:
            print(f"Extracted {frame_count} frames...", end='\r')
    
    clip.close()
    
    print(f"\n✓ Extracted {frame_count} frames")
    print(f"Saved to: {output_dir}")
    
    return output_dir


def create_reverse_loop_gif(input_video: str, output_path: str = None, fps: int = 10,
                           resize_factor: float = 1.0):
    """
    Create a GIF that plays forward then backward (boomerang effect)
    """
    video_path = Path(input_video)
    
    if not video_path.exists():
        raise FileNotFoundError(f"Video file not found: {input_video}")
    
    if output_path is None:
        output_path = video_path.parent / f"{video_path.stem}_loop.gif"
    
    print(f"Loading video: {input_video}")
    clip = VideoFileClip(str(video_path))
    
    # Resize if needed
    if resize_factor != 1.0:
        new_width = int(clip.size[0] * resize_factor)
        new_height = int(clip.size[1] * resize_factor)
        clip = clip.resize((new_width, new_height))
    
    # Create reverse clip
    from moviepy.video.fx.time_mirror import time_mirror
    reversed_clip = time_mirror(clip)
    
    # Concatenate forward and reverse
    from moviepy.editor import concatenate_videoclips
    loop_clip = concatenate_videoclips([clip, reversed_clip])
    
    print(f"Creating looping GIF...")
    loop_clip.write_gif(str(output_path), fps=fps, opt='optimizeplus')
    
    clip.close()
    loop_clip.close()
    
    print(f"✓ Looping GIF created: {output_path}")
    return output_path


def main():
    parser = argparse.ArgumentParser(
        description='Convert MP4 videos to animated GIFs or frame sequences',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Create a basic GIF
  python video_to_animation.py input.mp4
  
  # Create GIF with custom FPS and size
  python video_to_animation.py input.mp4 -o output.gif --fps 15 --resize 0.5
  
  # Create GIF from 5-8 second segment
  python video_to_animation.py input.mp4 --start 5 --end 8
  
  # Extract frames as images
  python video_to_animation.py input.mp4 --frames --output-dir ./frames
  
  # Create a boomerang/loop effect
  python video_to_animation.py input.mp4 --loop
        """
    )
    
    parser.add_argument('input', help='Input MP4 video file')
    parser.add_argument('-o', '--output', help='Output file path')
    parser.add_argument('--fps', type=int, default=10, help='Frames per second (default: 10)')
    parser.add_argument('--resize', type=float, default=1.0, 
                       help='Resize factor (0.5 = half size, default: 1.0)')
    parser.add_argument('--start', type=float, help='Start time in seconds')
    parser.add_argument('--end', type=float, help='End time in seconds')
    parser.add_argument('--frames', action='store_true', 
                       help='Extract frames instead of creating GIF')
    parser.add_argument('--output-dir', help='Output directory for frames')
    parser.add_argument('--format', default='png', help='Frame format (default: png)')
    parser.add_argument('--loop', action='store_true', 
                       help='Create a forward-backward loop (boomerang effect)')
    parser.add_argument('--no-optimize', action='store_true',
                       help='Disable GIF optimization (faster but larger file)')
    
    args = parser.parse_args()
    
    try:
        if args.frames:
            # Extract frames
            video_to_frames(
                args.input,
                output_dir=args.output_dir,
                frame_rate=args.fps,
                format=args.format
            )
        elif args.loop:
            # Create loop GIF
            create_reverse_loop_gif(
                args.input,
                output_path=args.output,
                fps=args.fps,
                resize_factor=args.resize
            )
        else:
            # Create regular GIF
            duration = None
            if args.start is not None or args.end is not None:
                start = args.start or 0
                end = args.end
                duration = (start, end) if end else None
            
            video_to_gif(
                args.input,
                output_path=args.output,
                fps=args.fps,
                resize_factor=args.resize,
                duration=duration,
                optimize=not args.no_optimize
            )
    
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
