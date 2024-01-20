#!/bin/bash

set -e

: "${BRANCH_SRC:=main}"
: "${BRANCH_DST:=dev}"

for arg; do
    echo -e "### \033[0;35m$arg\033[0m:"

    ( # Subshell
        cd "$arg"

        branch_final=$(git rev-parse --abbrev-ref HEAD)

        if git switch "$BRANCH_DST"; then
            git merge "$BRANCH_SRC"
            # git push
            git switch "$branch_final"
        fi
    )

    echo
done
