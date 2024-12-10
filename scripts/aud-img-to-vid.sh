#!/bin/bash

set -e

# This script lets you create a video starting from an audio file and an image

# Inspired by some commands from
# https://github.com/dmotte/misc/blob/main/snippets/README.md

# Usage example: ./aud-img-to-vid.sh myfile.{jpg,mp3,mp4}

readonly in_img=${1:?} in_aud=${2:?} out_vid=${3:?} \
    out_width=${4:1920} out_height=${5:1080}

ffmpeg -loop 1 -i "$in_img" -i "$in_aud" \
    -c:v libx264 -c:a aac -b:a 192k -shortest \
    -vf "scale=$out_width:$out_height:force_original_aspect_ratio=decrease,pad=$out_width:$out_height:(ow-iw)/2:(oh-ih)/2" \
    "$out_vid"