#!/bin/bash

set -e

echo "::group::$0: Preparation"
    if ! command -v shellcheck; then
        sudo apt-get update; sudo apt-get install -y shellcheck
    fi
    shellcheck --version
echo '::endgroup::'

if [ "$SHELLCHECK_USE_GIT_LS_FILES" = true ]
    then scripts=$(git ls-files \*.sh)
    else scripts=$(find . -name \*.sh)
fi
echo 'Scripts to check:'; echo "$scripts"
echo -n "$scripts" | xargs -rd\\n shellcheck
