#!/bin/bash

set -e

: "${BRANCH_SRC:=main}"
: "${BRANCH_DST:=dev}"

for i in "$@"; do
    echo -e "### \033[0;35m$i\033[0m:"

    ( # Subshell
        cd $i

        branch_final="$(git rev-parse --abbrev-ref HEAD)"

        if git switch "$BRANCH_DST"; then
            git merge "$BRANCH_SRC"
            # git push
            git switch "$branch_final"
        fi
    )

    echo
done
