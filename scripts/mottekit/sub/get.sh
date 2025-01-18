#!/bin/bash

set -e

readonly username=dmotte

readonly repo=${1:?}; shift
path=$(IFS=/; echo "$*")

curl -fsSL "https://raw.githubusercontent.com/$username/$repo/main/$path"
