#!/bin/bash

set -e

cd "$(dirname "$0")"

echo 'Hackdates started'

find jobs -mindepth 1 -maxdepth 1 -type f -name '*.sh' | LC_ALL=C sort |
    while IFS= read -r i; do echo "Running $i"; bash "$i"; done

echo 'Hackdates finished'
