#!/bin/bash

set -e

version_by_expr() {
    local git_ref; git_ref="$1"
    local expr; expr="$2"

    if [ "$git_ref" = 'refs/heads/main' ]; then
        local version; version=$(eval "$expr")
        [[ "$version" =~ ^v[0-9]+(\.[0-9]+)*$ ]] ||
            { echo "Got invalid version: $version" >&2; return 1; }
        echo "$version"
    fi
}

version_by_datetime() {
    local git_ref; git_ref="$1"

    if [ "$git_ref" = 'refs/heads/main' ]; then
        echo "v$(date -u +%Y.%m.%d.%H%M)"
    fi
}

version_by_tag() {
    local git_ref; git_ref="$1"

    local git_tag; git_tag="${git_ref#refs/tags/}"
    if [ "$git_tag" != "$git_ref" ]; then
        [[ "$git_tag" =~ ^v[0-9]+(\.[0-9]+)*$ ]] ||
            { echo "Got invalid version: $git_tag" >&2; return 1; }
        echo "$git_tag"
    fi
}
