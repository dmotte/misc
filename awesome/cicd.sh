#!/bin/bash

set -e

# This script should be run automatically by the CI/CD

cd "$(dirname "$0")"

[ "$GITHUB_EVENT_NAME" != schedule ] && git diff --quiet HEAD^ HEAD -- . && {
    echo "Skipping $0 as there are no changes in $PWD in the latest commit" \
        'and this is not a scheduled run'
    exit
}

# Tested with Python 3.12.4 on Windows 10
OUTPUT_DATA=false exec python3 parse.py < README.md
