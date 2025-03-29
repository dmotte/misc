#!/bin/bash

set -ex

v_local=$(yabridgectl --version | cut -d' ' -f2)

v_latest=$(curl -fsSL https://api.github.com/repos/robbert-vdh/yabridge/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
