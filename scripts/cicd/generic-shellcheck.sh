#!/bin/bash

set -e

echo "::group::$0: Preparation"
    if ! command -v shellcheck; then
        sudo apt-get update; sudo apt-get install -y shellcheck
    fi
    shellcheck --version
echo '::endgroup::'

if [ "$USE_GIT_LS_FILES" = true ]
    then files=$(git ls-files \*.sh)
    else files=$(find . -name \*.sh)
fi
echo 'Files to check:'; echo "$files"
echo -n "$files" | xargs -rd\\n shellcheck
