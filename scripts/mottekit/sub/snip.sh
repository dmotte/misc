#!/bin/bash

set -e

cd "$(dirname "$0")"

readonly text=$1

reporoot=$(git rev-parse --show-toplevel)
readonly snippets_file=$reporoot/snippets/README.md

[ -n "$text" ] || exec cat "$snippets_file"

exec grep -Fi --color=auto "$text" "$snippets_file"
