#!/bin/bash

set -e

# This script lets you create a video starting from an audio file and another
# video that will be looped

# Inspired by some commands from
# https://github.com/dmotte/misc/blob/main/snippets/README.md

# Usage example: ./aud-loop-to-vid.sh myfile{-loop.mp4,.mp3,.mp4}

readonly in_loop=${1:?} in_aud=${2:?} out_vid=${3:?} \
    out_width=${4:-1920} out_height=${5:-1080}

ffmpeg -stream_loop -1 -i "$in_loop" -i "$in_aud" \
    -c:a copy -shortest \
    -vf "scale=$out_width:$out_height:force_original_aspect_ratio=decrease,pad=$out_width:$out_height:(ow-iw)/2:(oh-ih)/2" \
    -map 0:v:0 -map 1:a:0 \
    "$out_vid"
