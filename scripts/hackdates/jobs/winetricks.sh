#!/bin/bash

set -e

echo 'Checking winetricks version'

text=$(winetricks --version)
v_local=$(echo "$text" | cut -d' ' -f1)

text=$(curl -fsSL https://api.github.com/repos/Winetricks/winetricks/releases/latest)
v_latest=$(echo "$text" | sed -En 's/^  "name": "([^"]+)",$/\1/p')

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
