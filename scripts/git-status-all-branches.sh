#!/bin/bash

set -e

for i in "$@"; do
    echo -e "### $i:"

    ( # Subshell
        cd "$i"

        branch_final="$(git rev-parse --abbrev-ref HEAD)"

        git fetch --all # Fetches all branches from all remotes

        git for-each-ref --format='%(refname:short)' refs/remotes | \
            while read -r i; do

            j="$(echo "$i" | cut -d/ -f2-)"
            if [ "$j" = 'HEAD' ]; then continue; fi

            git switch -q "$j"
            git status -bs
        done

        git switch -q "$branch_final"
    )
done
