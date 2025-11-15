#!/bin/bash

set -e

# This script can be used to generate a CSV tree of a specific directory

# Note: the semicolon character (";") is used as field separator, as it is
# normally not allowed in filenames

# Note: the output should be similar to "rclone lsf -R --format=pst"

# Usage example:
#   bash csvtree.sh mydir -mindepth 1 \! -name myexclude.txt > tree-mydir.csv

readonly main_dir=${1:?}; shift
readonly add_find_args=("$@")

tree=$(find "$main_dir" "${add_find_args[@]}" \( \
    \( -type d -printf '%P/;%#m;-1;DIR\n' \) \
    -o \( -type f -printf '%P;%#m;%s;%T@\n' \) \
\))

echo "$tree" | LC_ALL=C sort -t\; -k1,1
