#!/bin/bash

set -e

for i in "$@"; do
    n=$(git -C "$i" for-each-ref --format='%(objectname)' refs/heads | \
        sort | uniq | wc -l)
    if [ "$n" -ne 1 ]; then echo "$i: $n different branches"; fi

    branch_default="$(git -C "$i" symbolic-ref refs/remotes/origin/HEAD | \
        sed 's@^refs/remotes/origin/@@')"
    branch_current="$(git -C "$i" rev-parse --abbrev-ref HEAD)"
    if [ "$branch_current" != "$branch_default" ]; then
        echo "$i: on $branch_current"
    fi
done
