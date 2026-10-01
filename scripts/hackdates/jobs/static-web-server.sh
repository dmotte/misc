#!/bin/bash

set -e

echo 'Checking static-web-server version'

text=$(static-web-server --version)
v_local=$(echo -n v; echo "$text" | awk 'NR==1 {print $2}')

text=$(curl -fsSL -H'X-GitHub-Api-Version: 2026-03-10' \
    https://api.github.com/repos/static-web-server/static-web-server/releases/latest)
v_latest=$(echo "$text" | sed -En 's/^  "name": "([^"]+)",$/\1/p')

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
