#!/bin/bash

set -e

for i in "$@"; do
    echo -n "### $i: "
    ( # Subshell
        cd $i
        git fetch --all # Fetches all branches from all remotes
        git status -bs
    )
done
