#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_find_args=("$@")

files=$(find "$main_dir" -type f ! -path '*/.git/*' "${add_find_args[@]}")
files_bad=$(echo -n "$files" | xargs -rd\\n grep -ILPz '\n\z' || :)

[ -z "$files_bad" ] || {
    echo "$files_bad"
    echo 'Found some files with no newline at the end' >&2; exit 1
}
