#!/bin/bash

set -ex

readonly img=library/debian tag_ref=12

v_ref=$(curl -fsSL "https://registry.hub.docker.com/v2/repositories/$img/tags/$tag_ref" |
    jq -r .digest)

v_latest=$(curl -fsSL "https://registry.hub.docker.com/v2/repositories/$img/tags/latest" |
    jq -r .digest)

[ "$v_ref" = "$v_latest" ] || { echo "Version mismatch" >&2; exit 1; }
