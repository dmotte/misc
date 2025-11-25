#!/bin/bash

set -e

# This script reads a list of relative file and directory paths from stdin, and
# reproduces them under the destination directory by creating directories or
# copying files from the source directory accordingly

# Usage example: printf '%s\n' foo/{,bar.txt} | bash listcopy.sh mysrc mydst

dir_src=${1:?}; dir_dst=${2:?}

readonly automkdir=$LISTCOPY_AUTOMKDIR

add_cp_args=(); eval "add_cp_args=($LISTCOPY_ADD_CP_ARGS)"

dir_src=${dir_src%/}; dir_dst=${dir_dst%/}

################################################################################

while IFS= read -r i; do
    if [ "$automkdir" = true ]; then
        parent_dir=$(dirname "$dir_dst/$i")
        mkdir -pv "$parent_dir"
    fi

    if [[ "$i" = */ ]]; then
        i=${i%/}
        mode=$(stat -c%a "$dir_src/$i")
        mkdir -vm"$mode" "$dir_dst/$i"
    else
        cp -Tv "${add_cp_args[@]}" "$dir_src/$i" "$dir_dst/$i"
    fi
done
