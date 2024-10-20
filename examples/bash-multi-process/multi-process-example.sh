#!/bin/bash

set -e

# Example of how to spawn multiple concurrent processes in Bash and display
# both their stdout and stderr (with proper prefixes)

# Tested on Debian 12 (bookworm)

sample_service() {
    local name=${1:?}; shift
    while :; do
        sleep "$(shuf -i0-5 -n1)"; echo "This is stdout of $name"
        sleep "$(shuf -i0-5 -n1)"; echo "This is stderr of $name" >&2
    done
}

run_with_prefixes() {
    local name=${1:?}; shift
    { "$@" \
        > >(while read -r i; do echo "[$name:out] $i"; done) \
        2> >(while read -r i; do echo "[$name:err] $i"; done >&2)
    } 2>&1
}

################################################################################

trap 'kill $(jobs -p)' EXIT

echo 'Starting service myfirstsvc'
run_with_prefixes myfirstsvc sample_service myfirstsvc &
echo 'Starting service mysecondsvc'
run_with_prefixes mysecondsvc sample_service mysecondsvc &

wait # until all jobs finish
trap - EXIT
