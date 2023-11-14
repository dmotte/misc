#!/bin/bash

set -e

: "${RATIO:=1/2}"

# Create a directory for the output files
mkdir -p resized/

for fin; do
    fout="resized/$(basename "$fin")" # Output filename

    ffmpeg -i "$fin" -vf "scale=iw*$RATIO:ih*$RATIO" "$fout"
done
