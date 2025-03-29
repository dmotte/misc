#!/bin/bash

set -ex

v_local=$(k9s version -s | sed -En 's/^Version\s+(.+)$/\1/p')

v_latest=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
