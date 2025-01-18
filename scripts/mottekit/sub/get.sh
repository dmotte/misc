#!/bin/bash

set -e

readonly repo=${1:?}; shift
path=$(IFS=/; echo "$*")

curl -fsSL "https://raw.githubusercontent.com/dmotte/$repo/main/$path"
