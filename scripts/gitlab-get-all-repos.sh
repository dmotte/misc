#!/bin/bash

set -e

# Usage example:
# bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/gitlab-get-all-repos.sh) users/diaspora '(has("forked_from_project") | not) and .archived == false' | while read -r i; do git -C "$(basename "$i")" pull || git clone --depth=1 "git@gitlab.com:$i.git"; done

: "${GITLAB_URL:=https://gitlab.com/}"

owner="$1"
filter="${2:-true}"

if [ "$owner" = "${owner#users/}" ] && [ "$owner" = "${owner#groups/}" ]; then
    echo 'Invalid owner specified' >&2; exit 1
fi

page=1
while :; do
    # echo "Downloading page $page" >&2 # For debugging purposes

    response=$(curl -fsSL \
        -H "Private-Token: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/$owner/projects?per_page=100&page=$page")

    count=$(echo "$response" | jq length)

    [ "$count" -ne 0 ] || break

    echo "$response" | jq -r ".[] | select($filter) | .path_with_namespace"

    [ "$count" -eq 100 ] || break

    page=$((page + 1))
done
