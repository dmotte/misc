#!/bin/bash

set -e

echo 'Checking VirtualBox version'

text=$(vboxmanage --version)
v_local=$(echo "$text" | cut -dr -f1)

v_latest=$(curl -fsSL https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)

if [ "$v_local" = "$v_latest" ]
    then echo "OK ($v_local)"
    else echo "ERROR: local is $v_local but latest is $v_latest" >&2; exit 1
fi
