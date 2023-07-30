#!/bin/bash

set -e

: "${RATIO:=1/2}"

# Create a directory for the output files
mkdir -p resized/

for i in "$@"; do
    o="resized/$(basename "$i")" # Output filename

    ffmpeg -i "$i" -vf "scale=iw*$RATIO:ih*$RATIO" "$o"
done
