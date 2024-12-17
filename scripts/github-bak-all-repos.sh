#!/bin/bash

set -e

# Usage example: ./github-bak-all-repos.sh octocat ~/bak-octocat/

readonly owner=${1:?} dest=${2:?}

repos=$(bash "$(dirname "$0")/github-get-all-repos.sh" "users/$owner" \
    '.archived == false and .fork == false')
repos=$(echo "$repos" | tr -d '\r')

mkdir -p "$dest"

cd "$dest"

# We run the rest of the commands in a Bash subprocess spawned with "exec"
# because this script could be changed by a "git pull" in case it's part
# of one of the repos

{ read -rd '' script || [ -n "$script" ]; } << EOF
echo ${repos@Q} | while read -r i; do
    echo "Processing repo \$i"
    git -C "\${i#$owner/}" pull || git clone "https://github.com/\$i.git"
done
EOF

exec bash -ec "$script"
