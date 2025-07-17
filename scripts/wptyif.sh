#!/bin/bash

set -e

# This script runs a command in winpty only if needed. This is useful in
# Git Bash on Windows

# Check that stdin and stdout are TTYs. For more info, see
# https://github.com/rprichard/winpty/blob/7e59fe2d09adf0fa2aa606492e7ca98efbc5184e/src/unix-adapter/main.cc#L90
if [ -t 0 ] && [ -t 1 ]
    then exec winpty "$@"
    else exec "$@"
fi
