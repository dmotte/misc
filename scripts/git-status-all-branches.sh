#!/bin/bash

set -e

for arg; do
    echo -e "### $arg:"

    ( # Subshell
        cd "$arg"

        branch_final=$(git rev-parse --abbrev-ref HEAD)

        git fetch --all # Fetches all branches from all remotes

        git for-each-ref --format='%(refname)' refs/remotes |
            while read -r i; do

            j="${i#refs/remotes/origin/}"
            if [ "$j" = HEAD ] || [ "$j" = "$i" ] || [ -z "$j" ]; then
                continue
            fi

            git switch -q "$j"
            git status -bs
        done

        git switch -q "$branch_final"
    )
done
