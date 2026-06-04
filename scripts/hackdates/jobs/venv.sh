#!/bin/bash

set -e

readonly venv=~/apps/venv-yq

echo "Checking venv $venv pip upgrade dry-run"

text=$("$venv/bin/python3" -mpip install -Ur"$venv/requirements.txt" \
    --progress-bar=off --dry-run)
text=$(echo "$text" | grep '^Would install ' || :)

if [ -z "$text" ]
    then echo "OK"
    else echo "$text" >&2; exit 1
fi
