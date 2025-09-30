#!/bin/bash

set -e

cd "$(dirname "$0")"

readonly interval=${1:?} # in seconds

lastmod=$(stat -c%Y "$0")
now=$(date +%s)

if [ $((now - lastmod)) -ge "$interval" ]; then cat message.txt; fi
