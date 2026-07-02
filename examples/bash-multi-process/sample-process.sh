#!/bin/bash

set -e

readonly name=${1:?} iterations=${2:-10} sleep_range=${3:-0-5} \
    exit_code=${4:-0}; shift

################################################################################

echo "Process $name started. Iterations: $iterations," \
    "sleep range: $sleep_range, exit code: $exit_code"

for ((i = 0; i < iterations; i++)); do
    interval=$(shuf -i"$sleep_range" -n1); sleep "$interval"
    echo "This is stdout of $name"
    interval=$(shuf -i"$sleep_range" -n1); sleep "$interval"
    echo "This is stderr of $name" >&2
done

interval=$(shuf -i"$sleep_range" -n1); sleep "$interval"

echo "Process $name exiting with exit code $exit_code"

exit "$exit_code"
