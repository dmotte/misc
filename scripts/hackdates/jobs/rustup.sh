#!/bin/bash

set -e

echo 'Checking for updates to Rust toolchains and rustup'

text=$(rustup check 2>&1); echo "$text"

text=$(echo "$text" | grep -i 'Update available' || :)

[ -z "$text" ] || exit 1
