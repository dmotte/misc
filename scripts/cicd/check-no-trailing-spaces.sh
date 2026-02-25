#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_grep_args=("$@")

result=0
if [ "$USE_GIT_GREP" = true ]
    then git -C "$main_dir" grep -Il '\s$' "${add_grep_args[@]}"
    else grep -IRl --exclude-dir=.git "${add_grep_args[@]}" '\s$' "$main_dir"
fi || result=$?

[ "$result" != 0 ] || { echo 'Trailing spaces found in some files' >&2; exit 1; }
