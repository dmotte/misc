#!/bin/bash

set -e

cd "$(dirname "$0")"

# Example of how to spawn multiple concurrent processes in Bash and display
# both their stdout and stderr (with proper prefixes)

# Tested on Debian 13 (trixie)

# To run: time bash main.sh; echo $?

run_with_prefixes() {
    local name=${1:?}; shift
    { "$@" \
        > >(while IFS= read -r i || [ -n "$i" ]
            do echo "[$name:out] $i"; done) \
        2> >(while IFS= read -r i || [ -n "$i" ]
            do echo "[$name:err] $i"; done >&2)
    } 2>&1
}

################################################################################

trap 'jobs -p | xargs -rd\\n kill; wait' EXIT

echo 'Starting service foo'
{
    result=0
    run_with_prefixes foo bash sample-process.sh foo 3 0-3 0 || result=$?
    echo "Service foo exited with code $result"
} &

echo 'Starting service bar'
{
    result=0
    run_with_prefixes bar bash sample-process.sh bar 5 0-3 1 || result=$?
    echo "Service bar exited with code $result"
} &

wait # until all jobs finish
trap - EXIT
