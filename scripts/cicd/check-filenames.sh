#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly grep_args=("$@")

if [ "$USE_GIT_LS_FILES" = true ]; then
    # Relative paths of all the files (NO directories)
    filenames=$(git -C "$main_dir" ls-files)
else
    # Basenames of all the files AND directories
    filenames=$(find "$main_dir" \
        \! -name .git \! -path '*/.git/*' -printf '%f\n')
fi

if echo "$filenames" | grep "${grep_args[@]}"; then
    echo 'Pattern found in some filenames' >&2; exit 1
fi
