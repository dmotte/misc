#!/bin/bash

set -e

# Provision a remote server using a Bash script
# Usage example: ./provision.sh provisioning/ user@hostname -p2222

cd "$1"; shift

if [ ! -f main.sh ]; then
    echo 'File main.sh not found' >&2
    exit 1
fi

tar -cvzf- . | ssh "$@" '
    set -ex
    rm -rf /tmp/provisioning
    mkdir /tmp/provisioning
    tar -xvzf- -C/tmp/provisioning
    bash /tmp/provisioning/main.sh || result="$?"
    rm -rf /tmp/provisioning
    exit "${result:-0}"
'
