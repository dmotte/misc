#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_grep_args=("$@")

if grep -IRl --exclude-dir=.git "${add_grep_args[@]}" '\s$' "$main_dir"; then
    echo 'Trailing spaces found in some files' >&2; exit 1
fi
