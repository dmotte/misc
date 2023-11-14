#!/bin/bash

set -e

: "${OUTW:=640}" # Output width
: "${OUTH:=360}" # Output height
# : "${OUTW:=854}"
# : "${OUTH:=480}"

# Create a directory for the output files
mkdir -p resized/

for fin; do
    fout="resized/$(basename "$fin")" # Output filename

    ffmpeg -i "$fin" \
        -vf "scale=$OUTW:$OUTH:force_original_aspect_ratio=decrease,pad=$OUTW:$OUTH:(ow-iw)/2:(oh-ih)/2" \
        "$fout"
done
