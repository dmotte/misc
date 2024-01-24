#!/bin/bash

set -e

# This script produces a report about your Git repo in which, for each line of
# code, the timestamp it was written is reported

# Usage example: ./git-code-age.sh | LC_ALL=C sort -t, -k1

[ -z "$1" ] || cd "$1"

# Lists all non-empty regular (no symlinks) text files. See
# https://stackoverflow.com/a/24350112
git grep -Il '' | while read -r file; do
    git blame -t "$file" | sed -E \
        's|^.+\(.+\s+([0-9]+)\s+[+0-9]+\s+([0-9]+)\) (.*)$|\1,'"$file"',\2,\3|'
done
