#!/bin/bash

set -e

# This function aims to be as compact as possible, and compatible with the Dash
# shell (/bin/sh)

# This uses the "local myvar; myvar=..." approach instead of "local myvar=..."
# directly, because the "local" builtin command always returns 0 upon
# successful variable creation. See https://stackoverflow.com/a/9525025

# This puts a dummy "x" character at the end of the content variable to
# correctly preserve newlines, because the $(...) command substitution trims
# trailing newline characters. See https://stackoverflow.com/a/15184414

# Variables: c = content, s = checksum

fetch_and_check() {
    local c s; c="$(curl -fsSL "$1"; echo x)" && \
    s="$(echo -n "${c%x}" | sha256sum | cut -d' ' -f1)" && \
    if [ "$s" = "$2" ]; then echo -n "${c%x}"
    else echo "Checksum verification failed for $1: got $s, expected $2" >&2
    return 1; fi
}

################################ USAGE EXAMPLE #################################

script_content="$(fetch_and_check \
    'https://.../myscript.sh' \
    '1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d')"

script_content="${script_content//my-old-text/my-new-text}"

echo "$script_content"
# . <(echo "$script_content") # To run the script in the current environment
# bash <(echo "$script_content") # To run the script in a separate shell
