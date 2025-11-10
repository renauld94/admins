#!/usr/bin/env python3
"""Simple animation test"""

from moviepy.editor import VideoFileClip
import sys

video_path = "learning-platform-backup/jnj/module-02-core-python/session-2.01-Core Python Introduction/intro_video.mp4"

print("🎬 Loading video...")
clip = VideoFileClip(video_path)

print(f"Duration: {clip.duration}s")
print(f"Size: {clip.size}")
print(f"FPS: {clip.fps}")

print("\n✂️ Cutting 0-3 seconds...")
short_clip = clip.subclip(0, 3)

print("📐 Resizing to 50%...")
resized = short_clip.resize(0.5)

print("💾 Creating GIF...")
resized.write_gif("simple_test.gif", fps=10)

clip.close()
print("✅ Done! Check simple_test.gif")
