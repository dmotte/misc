#!/bin/bash

set -ex

v_local=$(helm version --template='{{.Version}}')

v_latest=$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest |
    sed -En 's/^  "tag_name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
