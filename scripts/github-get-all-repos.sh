#!/bin/bash

set -e

# Usage examples:
#   ./github-get-all-repos.sh users/octocat '.archived == false and .fork == false' .
#   ./github-get-all-repos.sh users/octocat true '.full_name, .description'
#   bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/github-get-all-repos.sh) users/octocat '.archived == false and .fork == false' | while read -r i; do git -C "$(basename "$i")" pull || git clone --depth=1 "git@github.com:$i.git"; done

readonly owner=${1:?} filter=${2:-true} fields=${3:-.full_name}

if [ "$owner" = "${owner#users/}" ] && [ "$owner" = "${owner#orgs/}" ]; then
    echo 'Invalid owner specified' >&2; exit 1
fi

page=1
while :; do
    [ "$GHGET_DEBUG" = true ] && echo "Downloading page $page" >&2

    if [ -n "$GITHUB_TOKEN" ]; then header_auth="Bearer $GITHUB_TOKEN"; fi
    response=$(curl -fsSL \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: $header_auth" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com/$owner/repos?per_page=100&page=$page")

    count=$(echo "$response" | jq length)

    [ "$count" != 0 ] || break

    echo "$response" | jq -cr ".[] | select($filter) | $fields"

    [ "$count" = 100 ] || break

    page=$((page + 1))
done
