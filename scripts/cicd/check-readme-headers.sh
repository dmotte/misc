#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_ls_args=("$@")

# We need to work with absolute paths, otherwise this script would fail in
# case a "./README.md" file exists
realpath_main_dir=$(realpath "$main_dir")

if [ "$USE_GIT_LS_FILES" = true ]; then
    files=$(git -C "$main_dir" ls-files \
        ':(icase)README.md' ':(icase)*/README.md' "${add_ls_args[@]}")
    files=$(printf '%s' "$files" | while IFS= read -r i || [ -n "$i" ]; do
        echo "$realpath_main_dir/$i"; done)
else
    files=$(find "$realpath_main_dir" -type f -iname README.md \
        "${add_ls_args[@]}")
fi

while IFS= read -r i || [ -n "$i" ]; do
    echo "Checking $i"

    parent_dir=${i%/*}
    expected="# ${parent_dir##*/}"
    actual=$(head -n1 "$i")

    [ "$expected" = "$actual" ] ||
        { echo "README header mismatch in $i: $actual" >&2; exit 1; }
done < <(printf '%s' "$files")
