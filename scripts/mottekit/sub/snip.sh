#!/bin/bash

set -e

cd "$(dirname "$0")"

readonly text=${1:?}

reporoot=$(git rev-parse --show-toplevel)

grep -Fi "$text" "$reporoot/snippets/README.md"
