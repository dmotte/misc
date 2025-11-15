#!/bin/bash

set -e

# Usage example:
#   time bash git-check-branches.sh ~/git/myrepo01 ~/git/myrepo02; echo $?

result=0

for arg; do
    n=$(git -C "$arg" for-each-ref --format='%(objectname)' refs/heads |
        LC_ALL=C sort -u | wc -l)
    if [ "$n" != 1 ]; then echo "$arg: $n different branches"; result=1; fi

    branch_default=$(git -C "$arg" symbolic-ref refs/remotes/origin/HEAD)
    branch_default=${branch_default#refs/remotes/origin/}
    branch_current=$(git -C "$arg" rev-parse --abbrev-ref HEAD)
    if [ "$branch_current" != "$branch_default" ]; then
        echo "$arg: on $branch_current"; result=1
    fi
done

exit "$result"
