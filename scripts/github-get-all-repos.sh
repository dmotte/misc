#!/bin/bash

set -e

# Example usage:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/github-get-all-repos.sh) users/octocat | while read -r i; do git clone --depth=1 "git@github.com:$i.git" || git -C "$(basename "$i")" pull; done

if [ "$1" = "${1#users/}" ] && [ "$1" = "${1#orgs/}" ]; then
    echo 'Invalid owner specified' 1>&2
    exit 1
fi

page=1
while :; do
    # echo "Downloading page $page" 1>&2 # For debugging purposes

    if [ -n "$GITHUB_TOKEN" ]; then header_auth="Bearer $GITHUB_TOKEN"; fi
    response=$(curl -fsSL \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: $header_auth" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com/$1/repos?per_page=100&page=$page")

    repos="$(echo "$response" | grep -i '"full_name":' | \
        sed -E 's/^ +"full_name": "(.+)",$/\1/')"

    [ -n "$repos" ] || break

    echo "$repos"

    [ "$(echo "$repos" | wc -l)" -eq 100 ] || break

    page=$((page + 1))
done
