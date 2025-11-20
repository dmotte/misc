#!/bin/bash

set -e

# This script produces a report about your Git repo in which, for each line of
# code, the timestamp it was written is reported

# Usage example: bash git-code-age.sh | LC_ALL=C sort -t, -k1,1n

[ -z "$1" ] || cd "$1"

# All non-empty regular (no symlinks) text files. See
# https://stackoverflow.com/a/24350112
files=$(git grep -Il '')

echo "$files" | while IFS= read -r file; do
    blame=$(git blame -t "$file")
    echo "$blame" | sed -E \
        's|^.+\(.+\s+([0-9]+)\s+[+0-9]+\s+([0-9]+)\) (.*)$|\1,'"$file"',\2,\3|'
done
