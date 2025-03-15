#!/bin/bash

set -e

cd "$(dirname "$0")"

readonly text=${1:?}

reporoot=$(git rev-parse --show-toplevel)

exec grep -Fi --color=auto "$text" "$reporoot/awesome/README.md"
