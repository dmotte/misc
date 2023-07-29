#!/bin/bash

set -e

for i in "$@"; do
    n=$(git -C "$i" for-each-ref --format='%(objectname)' refs/heads | \
        sort | uniq | wc -l)

    if [ $n -ne 1 ]; then echo "$i: $n"; fi
done
