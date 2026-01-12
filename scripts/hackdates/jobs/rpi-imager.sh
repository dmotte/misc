#!/bin/bash

set -e

echo 'Checking Raspberry Pi Imager (rpi-imager) version'

text=$(rpi-imager --version 2>&1)
v_local=$(echo "$text" | sed -En 's/^Raspberry Pi Imager (v.+)$/\1/p')

text=$(curl -fsSL https://api.github.com/repos/raspberrypi/rpi-imager/releases/latest)
v_latest=$(echo "$text" | sed -En 's/^  "tag_name": "([^"]+)",$/\1/p')

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
