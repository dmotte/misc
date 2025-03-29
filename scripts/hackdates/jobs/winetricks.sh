#!/bin/bash

set -ex

v_local=$(winetricks --version | cut -d' ' -f1)

v_latest=$(curl -fsSL https://api.github.com/repos/Winetricks/winetricks/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
