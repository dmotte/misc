#!/bin/bash

set -e

result=0

for arg; do
    n=$(git -C "$arg" for-each-ref --format='%(objectname)' refs/heads | \
        sort | uniq | wc -l)
    if [ "$n" -ne 1 ]; then echo "$arg: $n different branches"; result=1; fi

    branch_default="$(git -C "$arg" symbolic-ref refs/remotes/origin/HEAD | \
        sed 's@^refs/remotes/origin/@@')"
    branch_current="$(git -C "$arg" rev-parse --abbrev-ref HEAD)"
    if [ "$branch_current" != "$branch_default" ]; then
        echo "$arg: on $branch_current"; result=1
    fi
done

exit "$result"
