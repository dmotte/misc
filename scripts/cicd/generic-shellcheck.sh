#!/bin/bash

set -e

echo "::group::$0: Preparation"
    if ! command -v shellcheck; then
        sudo apt-get update; sudo apt-get install -y shellcheck
    fi
    shellcheck --version
echo '::endgroup::'

# shellcheck disable=SC2046
shellcheck $(find . -name \*.sh)
