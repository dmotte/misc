#!/bin/bash

set -ex

v_local=$(vboxmanage --version | cut -dr -f1)

v_latest=$(curl -fsSL https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT)

[ "$v_local" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
