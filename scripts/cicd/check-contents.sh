#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_grep_args=("$@")

result=0
if [ "$USE_GIT_GREP" = true ]
    then git -C "$main_dir" grep -Il "${add_grep_args[@]}"
    else grep -IRl --exclude-dir=.git "${add_grep_args[@]}" "$main_dir"
fi || result=$?

[ "$result" != 0 ] || { echo 'Pattern found in some files' >&2; exit 1; }
