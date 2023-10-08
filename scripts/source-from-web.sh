#!/bin/bash

set -e

fetch_and_check() {
    local content; content="$(curl -fsSL "$1")" && \
    if [ "$(echo "$content" | sha256sum | cut -d' ' -f1)" = "$2" ]
        then echo "$content"
        else echo "Checksum verification failed for $1" >&2; return 1
    fi
}

################################ USAGE EXAMPLE #################################

script_content="$(fetch_and_check \
    'https://.../myscript.sh' \
    '1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d')"

script_content="${script_content//my-old-text/my-new-text}"

echo "$script_content"
# . <(echo "$script_content") # To run the script in the current environment
# bash <(echo "$script_content") # To run the script in a separate shell
