#!/bin/bash

set -e

echo 'Checking for updates to Rust toolchains and rustup'

text=$(rustup check 2>&1)
text=$(echo "$text" | grep -i 'Update available' || :)

if [ -z "$text" ]
    then echo 'OK'
    else echo "$text" >&2; exit 1 # You can run "rustup update" to update
fi
