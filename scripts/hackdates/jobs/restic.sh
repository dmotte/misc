#!/bin/bash

set -ex

v_local=$(restic version | cut -d' ' -f1,2)

v_latest=$(curl -fsSL https://api.github.com/repos/restic/restic/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
