#!/bin/bash

set -e

echo 'Checking Helm version'

v_local=$(helm version --template='{{.Version}}')

text=$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest)
v_latest=$(echo "$text" | sed -En 's/^  "tag_name": "([^"]+)",$/\1/p')

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
