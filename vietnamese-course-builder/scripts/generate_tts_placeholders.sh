#!/usr/bin/env bash
set -euo pipefail
# Generate TTS placeholder MP3 files for missing audio entries listed in output/audio_manifest.json
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/output/audio_manifest.json"
OUTDIR="$ROOT/output/audio"
mkdir -p "$OUTDIR"

if [ ! -f "$MANIFEST" ]; then
  echo "Missing manifest: $MANIFEST" >&2
  exit 1
fi

HAS_ESPEAK=$(command -v espeak || true)
HAS_FF=$(command -v ffmpeg || true)

jq -r '.missing_audio[] | .suggested_name' "$MANIFEST" | while read -r fname; do
  out="$OUTDIR/$fname"
  if [ -f "$out" ]; then
    echo "Exists: $out"
    continue
  fi
  if [ -n "$HAS_ESPEAK" ] && [ -n "$HAS_FF" ]; then
    # Use espeak to generate WAV then ffmpeg to convert to mp3
    tmpwav=$(mktemp --suffix=.wav)
    espeak -v mb-us1 "Placeholder audio for $fname" -w "$tmpwav"
    ffmpeg -y -loglevel error -i "$tmpwav" -codec:a libmp3lame -qscale:a 4 "$out"
    rm -f "$tmpwav"
    echo "Generated: $out"
  elif [ -n "$HAS_FF" ]; then
    # Create a 0.5s silent mp3 via ffmpeg
    ffmpeg -y -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t 0.5 -q:a 9 "$out" -loglevel error
    echo "Created silent mp3: $out"
  else
    # Fallback: touch an empty placeholder and write a small note
    echo "Placeholder audio for $fname" > "$out".txt
    touch "$out"
    echo "Created placeholder file: $out (and $out.txt)"
  fi
done

echo "TTS placeholder generation complete. Files in $OUTDIR"
