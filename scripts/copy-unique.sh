#!/bin/bash

set -e

# This script copies a file, but only if the destination directory doesn't
# contain a file with the same SHA-256 checksum

# Usage example: ./copy-unique.sh myfile.txt mydir/bak-myfile-$(date +%Y-%m-%d-%H%M%S).txt

readonly file_src=${1:?} file_dst=${2:?}

[ -f "$file_src" ] || { echo "File $file_src not found" >&2; exit 1; }
[ ! -e "$file_dst" ] || { echo "File $file_dst already exists" >&2; exit 1; }

dir_dst=$(dirname "$file_dst")

[ -d "$dir_dst" ] || { echo "Dir $dir_dst not found" >&2; exit 1; }

pair_src=$(sha256sum "$file_src")
checksum_src=$(echo "$pair_src" | cut -d' ' -f1)

find_files_dst=$(find "$dir_dst" -mindepth 1 -maxdepth 1 -type f)
pairs_dst=$(echo "$find_files_dst" | xargs -rd\\n sha256sum)

if echo "$pairs_dst" | grep -i "^$checksum_src "; then
    echo 'A file with the same SHA-256 checksum is already present in' \
        'the destination directory' >&2
    exit 1
fi

cp -Tv "$file_src" "$file_dst"
