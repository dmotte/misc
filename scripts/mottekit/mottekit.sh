#!/bin/bash

set -e

mottekit_info() {
    echo " __  __       _   _       _  ___ _   "
    echo "|  \/  | ___ | |_| |_ ___| |/ (_) |_ "
    echo "| |\/| |/ _ \| __| __/ _ \ ' /| | __|"
    echo "| |  | | (_) | |_| ||  __/ . \| | |_ "
    echo "|_|  |_|\___/ \__|\__\___|_|\_\_|\__|"
    echo
    echo 'TODO version (commit)'
}

################################################################################

[ -n "$1" ] || { mottekit_info; exit; }

readonly subcmd=$1; shift

[ "$subcmd" = help ] || [ "$subcmd" = version ] && { mottekit_info; exit; }

path_script="$(dirname "$(dirname "$0")")/$subcmd.sh"
[ -e "$path_script" ] && exec "$path_script" "$@"

# TODO add subcommands: update, snip

echo "Invalid MotteKit subcommand: $subcmd" >&2; exit 1
