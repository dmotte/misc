#!/bin/bash

set -e

for i in "$@"; do
    echo -n "### $i: "
    ( # Subshell
        cd $i
        git fetch
        git status -bs
    )
done
