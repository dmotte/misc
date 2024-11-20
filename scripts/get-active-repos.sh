#!/bin/bash

set -e

readonly ignore_invalid=${IGNORE_INVALID:-false}
readonly min_datetime=${MIN_DATETIME:-1 year ago}

min_timestamp=$(date -d "$min_datetime" +%s)

for arg; do
    if [ "$ignore_invalid" = true ]; then
        last_commit_timestamp=$(git -C "$arg" log -1 --format=%ct 2>/dev/null || :)
        [ -n "$last_commit_timestamp" ] || continue
    else
        last_commit_timestamp=$(git -C "$arg" log -1 --format=%ct)
    fi

    if [ "$last_commit_timestamp" -ge "$min_timestamp" ]; then
        echo "$arg"
    fi
done
