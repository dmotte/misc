#!/bin/bash

set -e

readonly main_dir=${1:?}; shift

# We need to work with absolute paths, otherwise this script would fail in
# case a "./README.md" file exists
realpath_main_dir=$(realpath "$main_dir")
readmes=$(find "$realpath_main_dir" -type f -iname README.md)

echo "$readmes" | while IFS= read -r i; do
    echo "Checking $i"

    parent_dir=${i%/*}
    expected="# ${parent_dir##*/}"
    actual=$(head -n1 "$i")

    [ "$expected" = "$actual" ] ||
        { echo "README header mismatch in $i: $actual" >&2; exit 1; }
done
