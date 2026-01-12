#!/bin/bash

set -e

readonly img=library/debian tag_ref=13

echo "Checking digest of Docker Hub image $img:latest"

text=$(curl -fsSL "https://registry.hub.docker.com/v2/repositories/$img/tags/$tag_ref")
v_ref=$(echo "$text" | jq -r .digest)

text=$(curl -fsSL "https://registry.hub.docker.com/v2/repositories/$img/tags/latest")
v_latest=$(echo "$text" | jq -r .digest)

if [ "$v_ref" = "$v_latest" ]
    then echo "OK ($v_ref)"
    else echo "ERROR: reference is $v_ref but latest is $v_latest" >&2; exit 1
fi
