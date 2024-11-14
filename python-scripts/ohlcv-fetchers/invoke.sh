#!/bin/bash

set -e

basedir="$(dirname "$0")"

readonly fetcher=${1:?}; shift

if [[ "$(uname)" = MINGW* ]]
    then py=$basedir/venv/Scripts/python
    else py=$basedir/venv/bin/python3
fi

# We separately invoke the fetcher script in advance, to avoid masking its
# return value
data=$("$py" "$basedir/$fetcher.py" "$@")
echo "$data" | tr -d '\r'
