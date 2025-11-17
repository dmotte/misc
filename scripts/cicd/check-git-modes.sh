#!/bin/bash

set -e

git_ls_files=$(git ls-files -s)

if echo "$git_ls_files" | grep -v '^100644 '; then
    echo 'Found git files with unexpected mode bits' >&2; exit 1
fi
