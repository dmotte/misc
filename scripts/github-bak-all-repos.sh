#!/bin/bash

set -e

# Usage example:
#   time ./github-bak-all-repos.sh users/octocat ~/bak-octocat/; echo $?

readonly owner=${1:?} dest=${2:?}

repos=$(bash "$(dirname "$0")/github-get-all-repos.sh" "$owner" \
    '.archived == false and .fork == false')
repos=$(echo "$repos" | tr -d '\r')

for i in "${owner#users/}" "${owner#orgs/}"; do
    [ "$i" = "$owner" ] || { readonly owner_name=$i; break; }
done

mkdir -p "$dest"

cd "$dest"

# We run the rest of the commands in a Bash subprocess spawned with "exec"
# because this script could be changed by a "git pull" in case it's part
# of one of the repos

{ read -rd '' script || [ -n "$script" ]; } << EOF
echo ${repos@Q} | while read -r i; do
    echo "Processing repo \$i"
    git -C "\${i#$owner_name/}" ${GHBAK_PULL_ARGS:-} pull || {
        git clone ${GHBAK_CLONE_ARGS:-} "https://github.com/\$i.git"
    }
done
EOF

exec bash -ec "$script"
