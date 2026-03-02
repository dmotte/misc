#!/bin/bash

set -e

readonly main_dir=${1:?}; shift
readonly add_ls_args=("$@")

if [ "$USE_GIT_LS_FILES" = true ]; then
    files=$(git -C "$main_dir" ls-files "${add_ls_args[@]}")
    files=$(echo "$files" | while IFS= read -r i; do echo "$main_dir/$i"; done)
else
    files=$(find "$main_dir" -type f \! -path '*/.git/*' "${add_ls_args[@]}")
fi

# We don't use grep's "-I" option here because, since we also use "-z",
# grep is expecting NUL bytes, so its binary detection becomes
# unreliable
files_bad=$(echo -n "$files" | xargs -rd\\n grep -LPz '\n\z' || :)

# Quit early if files_bad is already empty, to avoid running "grep -I" with an
# empty string. Note that we need to specify the "0" exit code explicitly here
[ -n "$files_bad" ] || exit 0
# Filter out binary files
files_bad=$(echo "$files_bad" | while IFS= read -r i; do
    grep -I . "$i" >/dev/null || continue; echo "$i"; done)

[ -z "$files_bad" ] || {
    echo "$files_bad"
    echo 'Found some files with no newline at the end' >&2; exit 1
}
