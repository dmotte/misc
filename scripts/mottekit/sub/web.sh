#!/bin/bash

set -e

readonly username=dmotte

if [[ "$(uname)" = MINGW* ]]
    then open=start
    else open=xdg-open
fi

readonly repo=$1

[ -n "$repo" ] || exec $open "https://$username.github.io/"

shift
path=$(IFS=/; echo "$*")

[ -n "$path" ] || exec $open "https://$username.github.io/$repo"

exec $open "https://$username.github.io/$repo/$path"
