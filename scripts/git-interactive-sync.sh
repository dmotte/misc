#!/bin/bash

set -e

readonly repo_dir=${1:-.}

cd "$repo_dir"

echo 'Pulling from the remote'
git pull

echo 'Checking the repo status'
[ -n "$(git status -s)" ] || { echo 'The status is empty. Exiting'; exit; }

git status

echo 'Enter a commit message to stage all the changes + commit + push, or' \
    'leave it empty to exit.'
read -rp 'Message: ' msg

[ -n "$msg" ] || { echo 'No message provided. Exiting'; exit; }

if [ "$GITSYNC_CONFIRMATION" = true ]; then
    read -rp 'Are you sure [y/N]? ' sure
    [[ "${sure:-n}" =~ ^[Yy]$ ]] || { echo 'Aborted. Exiting'; exit; }
fi

echo 'Staging all the changes'
git add .

echo 'Creating Git commit'
git commit -m "$msg"

echo 'Pushing to the remote'
git push
