#!/bin/bash

set -e

echo 'Checking for updates to Rust toolchains and rustup'

text=$(rustup check 2>&1); echo "$text"

text=$(echo "$text" | grep -i 'Update available' || :)

if [ -z "$text" ]
    then echo 'OK'
    else echo 'ERROR: some updates are available. Run "rustup update" to' \
        'update' >&2; exit 1
fi
