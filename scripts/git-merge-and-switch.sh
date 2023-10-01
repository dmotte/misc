#!/bin/bash

set -e

branch_from=dev
branch_to=main
branch_final=main

for i in "$@"; do
    echo -e "### \033[0;35m$i\033[0m:"

    ( # Subshell
        cd $i

        if git switch "$branch_from"; then
            git merge "$branch_to"
            # git push
            git switch "$branch_final"
        fi
    )

    echo
done
