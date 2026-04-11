#!/bin/bash

set -e

readonly template=${1:?} dir=${2:?} displaypath=${3:?}

################################################################################

html_pre=$(sed '\|^\s*// -----BEGIN DIRECTORY DATA-----$|,$d' "$template")
html_post=$(sed '1,\|^\s*// -----END DIRECTORY DATA-----$|d' "$template")

items_text=$(find "$dir" -mindepth 1 -maxdepth 1 \
    -type d -printf '%T@ -1 %P\n' -o \
    -type f \! -name 'index.html' -printf '%T@ %s %P\n')
items_json=$(echo "$items_text" | jq -Rcs 'split("\n") | map(
    capture("^(?<t>[0-9.]+) (?<s>-?[0-9]+) (?<n>.+)$") |
    [.n, (.s | tonumber), (.t | tonumber * 1000 | floor)])')

displaypath_json=$(echo -n "$displaypath" | jq -Rs .)

{
    echo "$html_pre"
    echo "static dirPath = $displaypath_json;"
    echo "static dirContent = $items_json;"
    echo "$html_post"
} | minify --type=html
