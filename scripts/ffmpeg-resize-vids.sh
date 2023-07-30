#!/bin/bash

set -e

p_outw=640  # Output width
p_outh=360  # Output height
#p_outw=854
#p_outh=480

# Create a directory for the output files
mkdir -p resized/

for i in "$@"; do
    bn="$(basename "$i")"  # Basename
    o="resized/$bn"        # Output filename

    ffmpeg -i "$i" \
        -vf "scale=$p_outw:$p_outh:force_original_aspect_ratio=decrease,pad=$p_outw:$p_outh:(ow-iw)/2:(oh-ih)/2" \
        "$o"
done
