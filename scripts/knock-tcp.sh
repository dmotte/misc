#!/bin/bash

set -e

# This script can be used to perform TCP port knocking

# Usage example:
#   ./knock-tcp.sh myserver.example.com 1111 2222 3333

readonly host=${1:?}; shift

if command -v curl >/dev/null; then
    echo 'Using curl to perform port knocking'
    knock_port() { curl -m0.1 "http://${1:?}:${2:?}" || :; }
elif command -v wget >/dev/null; then
    echo 'Using wget to perform port knocking'
    knock_port() { wget -t1 -T.1 -O- "http://${1:?}:${2:?}" || :; }
else
    echo 'Using ssh to perform port knocking'
    knock_port() { ssh -oConnectionAttempts=1 -oConnectTimeout=1 \
        "${1:?}" -p"${2:?}" || :; }
fi

for arg; do
    echo "Knocking port $arg"
    knock_port "$host" "$arg"
done
