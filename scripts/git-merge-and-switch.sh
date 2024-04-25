#!/bin/bash

set -e

branch_src="${BRANCH_SRC:-main}"
branch_dst="${BRANCH_DST:-dev}"

for arg; do
    echo -e "### \033[0;35m$arg\033[0m:"

    ( # Subshell
        cd "$arg"

        branch_final=$(git rev-parse --abbrev-ref HEAD)

        if git switch "$branch_dst"; then
            git merge "$branch_src"
            # git push
            git switch "$branch_final"
        fi
    )

    echo
done
