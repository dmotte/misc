#!/bin/bash

set -e

for i in "$@"; do
    n=$(git -C "$i" for-each-ref --format='%(objectname)' refs/heads | \
        sort | uniq | wc -l)
    if [ "$n" -ne 1 ]; then echo "$i: $n different branches"; fi

    branch="$(git -C "$i" rev-parse --abbrev-ref HEAD)"
    if [ "$branch" != main ]; then echo "$i: on $branch"; fi
done
