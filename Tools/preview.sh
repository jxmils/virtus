#!/bin/bash
# Renders the app preview video for the App Store (iPhone 6.9" slot: 886x1920, H.264, 20.5 s, no audio)
# from the scene PNGs that `screens --preview` writes. Needs ffmpeg (brew install ffmpeg).
set -euo pipefail
cd "$(dirname "$0")/.."
DIR=${1:-build/preview}
OUT=${2:-build/store/preview-6.9.mp4}
HOLD=4      # seconds each scene stays
X=0.7       # crossfade length
scenes=("$DIR"/1-today.png "$DIR"/2-quote.png "$DIR"/3-profile.png "$DIR"/4-widgets.png "$DIR"/5-archive.png "$DIR"/6-end.png)
inputs=(); for s in "${scenes[@]}"; do inputs+=(-loop 1 -t "$HOLD" -i "$s"); done
n=${#scenes[@]}
filter=""; prev="[0:v]"; offset=0
for ((i=1; i<n; i++)); do
  offset=$(python3 -c "print(round($HOLD*$i - $X*$i, 3))")
  out="[v$i]"; [ $i -eq $((n-1)) ] && out="[vx]"
  filter+="${prev}[$i:v]xfade=transition=fade:duration=$X:offset=$offset$out;"
  prev="$out"
done
total=$(python3 -c "print(round($HOLD*$n - $X*($n-1), 3))")
filter+="[vx]fade=t=in:st=0:d=0.6,fade=t=out:st=$(python3 -c "print(round($total-0.7, 3))"):d=0.7,format=yuv420p[v]"
ffmpeg -y -loglevel error "${inputs[@]}" -filter_complex "$filter" -map "[v]" -r 30 \
  -c:v libx264 -profile:v high -level 4.0 -b:v 10M -maxrate 12M -bufsize 20M -pix_fmt yuv420p -movflags +faststart "$OUT"
ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,duration,codec_name -of default=nw=1 "$OUT"
