#!/bin/bash

set -e

echo 'Checking for updates to Rust toolchains and rustup'

# This will return status code 100 if there are any updates. See
# https://blog.rust-lang.org/2026/03/12/Rustup-1.29.0/
exec rustup check # You can run "rustup update" to update
