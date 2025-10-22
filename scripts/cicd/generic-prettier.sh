#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../../bash-libs/fetch-and-check.sh"

echo "::group::$0: Preparation"
    if ! command -v npm; then
        bash <(fetch_and_check \
            'https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh' \
            '2d8359a64a3cb07c02389ad88ceecd43f2fa469c06104f92f98df5b6f315275f')
        # shellcheck source=/dev/null
        . ~/.nvm/nvm.sh
        nvm install --lts
    fi
    npm --version

    npm install -g prettier
    npx prettier --version
echo '::endgroup::'

npx prettier -c .
