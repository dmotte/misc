#!/bin/bash

set -e

# This script can be used to process an audio file based on the values computed
# by the Python scripts

options=$(getopt -o +p:l:c -l perc-clipping:,level-trim:,clear-metadata -- "$@")
eval "set -- $options"

perc_clipping=''
level_trim=''
clear_metadata=n

while :; do
    case $1 in
        -p|--perc-clipping) shift; perc_clipping=$1;;
        -l|--level-trim) shift; level_trim=$1;;
        -c|--clear-metadata) clear_metadata=y;;
        --) shift; break;;
    esac
    shift
done

readonly file_in=${1:?} file_out=${2:?}

args_amp=()
args_trim=()

[ -n "$perc_clipping" ] && args_amp+=("--perc-clipping=$perc_clipping")
[ -n "$level_trim" ] && args_trim+=(--level-{start,end}"=$level_trim")

################################################################################

basedir=$(dirname "$0")

if [[ "$(uname)" = MINGW* ]]
    then py=$basedir/venv/Scripts/python
    else py=$basedir/venv/bin/python3
fi

echo 'Computing amplification values'
values_amp=$("$py" "$basedir/compute-amp.py" "${args_amp[@]}" \
    "$file_in" -f'{:.6f}')
echo "$values_amp"

echo 'Computing trimming values'
values_trim=$("$py" "$basedir/compute-trim.py" "${args_trim[@]}" \
    "$file_in" -f'{:.6f}')
echo "$values_trim"

gain_factor="$(echo "$values_amp" | grep '^gain_factor=')"
gain_factor=${gain_factor#gain_factor=}

time_start="$(echo "$values_trim" | grep '^time_start=')"
time_start=${time_start#time_start=}
time_end="$(echo "$values_trim" | grep '^time_end=')"
time_end=${time_end#time_end=}

################################################################################

args_ffmpeg=()

[ "$time_start" != -1 ] && args_ffmpeg+=(-ss "$time_start")
[ "$time_end" != -1 ] && args_ffmpeg+=(-to "$time_end")

args_ffmpeg+=(-af "volume=$gain_factor")

[ "$clear_metadata" = y ] && args_ffmpeg+=(-map 0:a -map_metadata -1)

ffmpeg -i "$file_in" "${args_ffmpeg[@]}" "$file_out"
