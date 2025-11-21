#!/bin/bash

set -e

# Usage example:
#   time bash git-status-all-branches.sh ~/git/myrepo01 ~/git/myrepo02; echo $?

for arg; do
    echo "### $arg:"

    ( # Subshell
        cd "$arg"

        branch_final=$(git rev-parse --abbrev-ref HEAD)

        git fetch --all # Fetch all branches from all the remotes

        refs_remotes=$(git for-each-ref --format='%(refname)' refs/remotes)
        echo "$refs_remotes" | while IFS= read -r i; do
            j=${i#refs/remotes/origin/}
            if [ "$j" = HEAD ] || [ "$j" = "$i" ] || [ -z "$j" ]
                then continue; fi

            git switch -q "$j"
            git status -bs
        done

        git switch -q "$branch_final"
    )
done
