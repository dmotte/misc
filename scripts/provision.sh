#!/bin/bash

set -e

# Provision a remote server using a directory with a Bash script
# Usage example:
#   ./provision.sh provisioning/ '--arg01 --arg02' ssh user@hostname -p2222

prov_dir="$1"; shift
remote_args="$1"; shift

if [ ! -f "$prov_dir/main.sh" ]; then
    echo 'File main.sh not found' >&2
    exit 1
fi

# Operations are split in two separate connections because we want the
# "$prov_dir/main.sh" script to be able to read from our stdin

tar -cvzf- -C "$prov_dir" . | "$@" '
    set -ex
    rm -rf /tmp/provisioning
    mkdir /tmp/provisioning
    tar -xvzf- -C/tmp/provisioning
'

# shellcheck disable=SC2016
"$@" '
    set -ex
    bash /tmp/provisioning/main.sh '"$remote_args"' || result="$?"
    rm -rf /tmp/provisioning
    exit "${result:-0}"
'
