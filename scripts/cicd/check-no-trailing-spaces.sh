#!/bin/bash

set -e

readonly main_dir=${1:?}; shift

if grep -IRl --exclude-dir=.git '\s$' "$main_dir"; then
    echo 'Trailing spaces found in some files' >&2; exit 1
fi
