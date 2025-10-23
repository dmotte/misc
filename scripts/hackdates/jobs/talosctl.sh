#!/bin/bash

set -ex

v_local=$(talosctl version --client --short | sed -En 's/^Client (.+)$/\1/p')

v_latest=$(curl -fsSL https://api.github.com/repos/siderolabs/talos/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo 'Version mismatch' >&2; exit 1; }
