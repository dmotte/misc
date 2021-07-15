#!/bin/bash

set -e

#OUTPUT_WIDTH=854; OUTPUT_HEIGHT=480
OUTPUT_WIDTH=640; OUTPUT_HEIGHT=360

for i in "$@"; do
    INPUT_FILENAME="$i"
    OUTPUT_FILENAME="${i}-resized.mp4"

    ffmpeg -i "$INPUT_FILENAME" \
        -vf "scale=$OUTPUT_WIDTH:$OUTPUT_HEIGHT:force_original_aspect_ratio=decrease,pad=$OUTPUT_WIDTH:$OUTPUT_HEIGHT:(ow-iw)/2:(oh-ih)/2" \
        "$OUTPUT_FILENAME"
done
