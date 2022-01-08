#!/bin/bash

set -e

# Parameters
p_ratio="1/2"

# Create a directory in which to save the output files
mkdir -p resized/

for i in "$@"; do
    bn="$(basename "$i")"  # Basename
    o="resized/$bn"        # Output filename

    ffmpeg -i "$i" -vf scale="iw*$p_ratio:ih*$p_ratio" "$o"
done
