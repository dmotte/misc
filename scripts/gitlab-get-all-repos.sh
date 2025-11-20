#!/bin/bash

set -e

# Usage examples:
#   bash gitlab-get-all-repos.sh users/diaspora '(has("forked_from_project") | not) and .archived == false' .
#   bash gitlab-get-all-repos.sh users/diaspora true '.path_with_namespace, .description'
#   bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/gitlab-get-all-repos.sh) users/diaspora '(has("forked_from_project") | not) and .archived == false' | while IFS= read -r i; do git -C "$(basename "$i")" pull || git clone --depth=1 "git@gitlab.com:$i.git"; done

readonly gitlab_url=${GITLAB_URL:-https://gitlab.com/}
readonly owner=${1:?} filter=${2:-true} fields=${3:-.path_with_namespace}

if [ "$owner" = "${owner#users/}" ] && [ "$owner" = "${owner#groups/}" ]; then
    echo 'Invalid owner specified' >&2; exit 1
fi

page=1
while :; do
    [ "$GLGET_DEBUG" = true ] && echo "Downloading page $page" >&2

    response=$(curl -fsSL \
        -H "Private-Token: $GITLAB_TOKEN" \
        "$gitlab_url/api/v4/$owner/projects?per_page=100&page=$page")

    count=$(echo "$response" | jq length)

    [ "$count" != 0 ] || break

    echo "$response" | jq -cr ".[] | select($filter) | $fields"

    [ "$count" = 100 ] || break

    page=$((page + 1))
done
