#!/bin/bash

set -e

echo "::group::$0: Preparation"
    if ! command -v shellcheck; then
        sudo apt-get update; sudo apt-get install -y shellcheck
    fi
    shellcheck --version
echo '::endgroup::'

scripts="$(find . -name \*.sh)"

echo 'Scripts to check:'; echo "$scripts"

if [ -n "$scripts" ]; then
    # shellcheck disable=SC2086
    shellcheck $scripts
fi
