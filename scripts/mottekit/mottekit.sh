#!/bin/bash

set -e

basedir=$(dirname "$0")

mottekit_info() {
    echo " __  __       _   _       _  ___ _   "
    echo "|  \/  | ___ | |_| |_ ___| |/ (_) |_ "
    echo "| |\/| |/ _ \| __| __/ _ \ ' /| | __|"
    echo "| |  | | (_) | |_| ||  __/ . \| | |_ "
    echo "|_|  |_|\___/ \__|\__\___|_|\_\_|\__|"
    echo
    local version; version=$(TZ=UTC git log -1 \
        --date=format-local:'v%Y.%m.%d.%H%M' --format='%cd')
    local commit; commit=$(git rev-parse --short HEAD)
    echo "MotteKit version $version (commit $commit)"
}

mottekit_snip() {
    grep -Fi "${1:?}" "$basedir/../../snippets/README.md"
}

################################################################################

[ -n "$1" ] || { mottekit_info; exit; }

readonly subcmd=$1; shift

[ "$subcmd" = help ] || [ "$subcmd" = version ] && { mottekit_info; exit; }
[ "$subcmd" = snip ] && { mottekit_snip "$@"; exit; }

for i in ~/.mottekit/overrides/"$subcmd.sh" \
    "$basedir/$subcmd.sh" \
    "$(dirname "$basedir")/$subcmd.sh"

    do [ -e "$i" ] && exec bash "$i" "$@"
done

# TODO add subcommands: update, autoupdate (?)

echo "Invalid MotteKit subcommand: $subcmd. Run \"mottekit help\" for help" >&2
exit 1
