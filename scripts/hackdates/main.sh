#!/bin/bash

set -e

cd "$(dirname "$0")"

echo 'Hackdates started'

scripts=$(find jobs -mindepth 1 -maxdepth 1 -type f -name '*.sh')
while IFS= read -r i || [ -n "$i" ]; do
    echo "Running $i"; bash "$i"
done < <(printf '%s' "$scripts" | LC_ALL=C sort)

echo 'Hackdates finished'
