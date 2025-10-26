#!/bin/bash

set -ex

v_local=$(echo -n v; rpi-imager --version 2>&1 | sed -En 's/^rpi-imager version (.+)$/\1/p')

v_latest=$(curl -fsSL https://api.github.com/repos/raspberrypi/rpi-imager/releases/latest |
    sed -En 's/^  "name": "([^"]+)",$/\1/p')

[ "$v_local" = "$v_latest" ] || { echo 'Version mismatch' >&2; exit 1; }
