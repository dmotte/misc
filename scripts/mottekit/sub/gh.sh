#!/bin/bash

set -e

readonly username=dmotte branch=main

if [[ "$(uname)" = MINGW* ]]
    then open=start
    else open=xdg-open
fi

readonly repo=$1

[ -n "$repo" ] || exec $open "https://github.com/$username"

shift
path=$(IFS=/; echo "$*")

[ -n "$path" ] || exec $open "https://github.com/$username/$repo"

exec $open "https://github.com/$username/$repo/tree/$branch/$path"
