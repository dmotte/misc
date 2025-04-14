#!/bin/bash

set -e

echo 'Pulling from the remote'
git pull

echo 'Checking the repo status'
if [ -n "$(git status -s)" ]; then
    git status

    echo 'Enter a commit message to stage + commit + push, or leave it' \
        'empty to skip.'
    read -rp 'Message: ' msg

    if [ -n "$msg" ]; then
        echo 'Staging all the changes'
        git add .

        echo 'Creating Git commit'
        git commit -m "$msg"

        echo 'Pushing to the remote'
        git push
    fi
else
    echo 'The status is empty'
fi
