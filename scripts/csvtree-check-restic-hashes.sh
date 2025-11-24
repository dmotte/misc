#!/bin/bash

set -e

# This script takes a CSV directory tree (generated with the "csvtree.sh"
# script) as input, and checks that the basenames of all the files (except
# "config") match with their recorded SHA-256 hashes (checksums). This is
# useful for restic repositories, where file names are derived from their
# content hashes

# Usage example:
#   time CSVTREE_HASH_FUNC=sha256 bash csvtree.sh my-restic-repo </dev/null |
#     bash csvtree-check-restic-hashes.sh; echo $?

while IFS= read -r line; do
    [[ "$line" =~ ^([^;]+)\;([^;]+)\;([^;]+)\;([^;]+)\;([^;]*)$ ]] ||
        { echo "Invalid line: $line" >&2; exit 1; }

    path=${BASH_REMATCH[1]}
    lastmod=${BASH_REMATCH[4]}
    hash=${BASH_REMATCH[5]}

    { [ "$path" != config ] && [ "$lastmod" != DIR ]; } || continue

    bn=${path##*/}

    [ "$bn" = "$hash" ] ||
        { echo "File basename and hash differ: $line" >&2; exit 1; }
done
