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

basedir=$(dirname "$0")

for i in ~/.mottekit/overrides/"$subcmd.sh" \
    "$basedir/$subcmd.sh" \
    "$(dirname "$basedir")/$subcmd.sh"

    do [ -e "$i" ] && exec bash "$i" "$@"
done

# TODO add subcommands: snip, update, autoupdate (?)

echo "Invalid MotteKit subcommand: $subcmd. Run \"mottekit help\" for help" >&2
exit 1
