#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../fetch-and-check.sh"

echo "::group::$0: Preparation"
    if ! command -v npm; then
        bash <(fetch_and_check \
            'https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh' \
            '69da4f89f430cd5d6e591c2ccfa2e9e3ad55564ba60f651f00da85e04010c640')
        # shellcheck source=/dev/null
        . ~/.nvm/nvm.sh
        nvm install --lts
    fi
    npm --version

    npm install -g prettier
    npx prettier --version
echo '::endgroup::'

npx prettier -c .
