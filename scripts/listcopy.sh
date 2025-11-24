#!/bin/bash

set -e

# This script reads a list of relative file and directory paths from stdin, and
# reproduces them under the destination directory by creating directories or
# copying files from the source directory accordingly

# Usage example: printf '%s\n' foo/{,bar.txt} | bash listcopy.sh mysrc mydst

dir_src=${1:?}; dir_dst=${2:?}

dir_src=${dir_src%/}; dir_dst=${dir_dst%/}

################################################################################

while IFS= read -r i; do
    if [[ "$i" = */ ]]; then
        i=${i%/}
        mode=$(stat -c%a "$dir_src/$i")
        mkdir -vm"$mode" "$dir_dst/$i"
    else
        cp -Tipv "$dir_src/$i" "$dir_dst/$i"
    fi
done
