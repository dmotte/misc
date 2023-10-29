#!/bin/bash

set -e

# Provision a remote server using a Bash script
# Usage example: ./provision.sh provisioning/ user@hostname -p2222

prov_dir="$1"; shift

if [ ! -f "$prov_dir/main.sh" ]; then
    echo 'File main.sh not found' >&2
    exit 1
fi

tar -cvzf- "$prov_dir" | ssh "$@" '
    set -ex
    rm -rf /tmp/provisioning
    tar -xvzf- -C/tmp
    bash /tmp/provisioning/main.sh || result="$?"
    rm -rf /tmp/provisioning
    exit "${result:-0}"
'
