#!/bin/bash

set -e

# This script can be used to extract one or more time ranges from a
# media file into separate clips

# Usage example:
#   bash clip-media.sh myvid.mp4 -00:20 -00:40 00:45-00:50 01:00-

readonly src=${1:?}; shift

################################################################################

dn=$(dirname "$src"); bn_src=$(basename "$src")

stem=${bn_src%.*}; ext=${bn_src##*.}
[ "$stem" != "$ext" ] || ext=''

t_end_old=0
for i in {01..99}; do
    [ -n "$1" ] || break
    arg=$1; shift

    IFS=- read -r t_start t_end <<< "$arg"
    [ -n "$t_start" ] || t_start=$t_end_old

    split_flags=(-ss "$t_start")
    [ -z "$t_end" ] || split_flags+=(-to "$t_end")

    dst=$dn/$stem-$i.$ext

    echo "Extracting $t_start - ${t_end:-end} to $dst"
    ffmpeg "${split_flags[@]}" -i "$src" \
        -c copy -avoid_negative_ts make_zero "$dst"

    [ -z "$t_end" ] || t_end_old=$t_end
done
