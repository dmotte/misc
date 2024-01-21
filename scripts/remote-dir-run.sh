#!/bin/bash

set -e

# This script copies a local directory onto a remote server and runs the
# main.sh script inside it

# Usage example:
#   ./remote-dir-run.sh mydir ssh user@hostname -p2222

[ $# -ge 1 ] || { echo 'Not enough args' >&2; exit 1; }
local_dir="$1"; shift

[ -f "$local_dir/main.sh" ] || { echo 'File main.sh not found' >&2; exit 1; }

: "${RDR_CMD:=bash main.sh}"
: "${RDR_SHELL_OPTIONS:=-e}"

remote_dir="/tmp/remote-dir-run-$(date +%Y-%m-%d-%H%M%S)"

# Operations are split in two separate connections because we want the
# "$local_dir/main.sh" script to be able to read from our end's stdin

tar -cvzf- -C"$local_dir" . | "$@" '
    set '"$RDR_SHELL_OPTIONS"'
    rm -rf '"$remote_dir"'
    mkdir '"$remote_dir"'
    tar -xvzf- -C'"$remote_dir"'
'

# shellcheck disable=SC2016
"$@" '
    set '"$RDR_SHELL_OPTIONS"'
    cd '"$remote_dir"'
    '"$RDR_CMD"' || result=$?
    rm -rf '"$remote_dir"'
    exit "${result:-0}"
'
