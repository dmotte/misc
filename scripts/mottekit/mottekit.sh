#!/bin/bash

set -e

basedir=$(dirname "$0")

readonly builtin_subcmds=(info help version update source sudo)

# shellcheck disable=SC2317
subcmd_info() {
    echo " __  __       _   _       _  ___ _   "
    echo "|  \/  | ___ | |_| |_ ___| |/ (_) |_ "
    echo "| |\/| |/ _ \| __| __/ _ \ ' /| | __|"
    echo "| |  | | (_) | |_| ||  __/ . \| | |_ "
    echo "|_|  |_|\___/ \__|\__\___|_|\_\_|\__|"
    echo
    echo "Multi-purpose \"Swiss Army knife\" CLI tool"
    local version; version=$(TZ=UTC git -C "$basedir" log -1 \
        --date=format-local:'v%Y.%m.%d.%H%M' --format='%cd')
    local commit; commit=$(git -C "$basedir" rev-parse --short HEAD)
    echo "MotteKit version $version (commit $commit)"
    echo
    echo '/!\ WARNING: this tool can potentially harm your system! Use it at' \
        'your own risk, and make sure you always understand what you are' \
        'doing before proceeding.'
    echo
    echo 'Available subcommands:'
    echo

    find_with_category() { find "${1:?}" -type f -name '*.sh' \
        -printf "${2:?} %P\n"; }

    # We generate fake paths for builtin subcommands
    items=$(printf 'builtin %s.sh\n' "${builtin_subcmds[@]}")

    if [ -e "$basedir/overrides" ]; then
        items+=$'\n'$(find_with_category "$basedir/overrides" overrides)
    fi

    for i in sub ..; do
        items+=$'\n'$(find_with_category "$basedir/$i" "$i")
    done

    echo "$items" | while read -r category subpath; do
        echo "- ($category) ${subpath%.sh}"
    done
}
# shellcheck disable=SC2317
subcmd_help() { subcmd_info "$@"; }
# shellcheck disable=SC2317
subcmd_version() { subcmd_info "$@"; }

# shellcheck disable=SC2317
subcmd_update() {
    echo 'Updating MotteKit'

    # We run the pull in a Bash process spawned with "exec" because this
    # script could be changed by it
    exec bash -ec "git -C ${basedir@Q} pull"
}

# shellcheck disable=SC2317
subcmd_source() {
    readonly subcmd_name=${1:?}

    for i in "$basedir"/{overrides,sub,..}/"$subcmd_name.sh"; do
        [ -e "$i" ] || continue
        # shellcheck disable=SC2093
        exec cat "$i"
    done

    echo "Subcommand not found: $subcmd_name" >&2; exit 1
}

# shellcheck disable=SC2317
subcmd_sudo() { exec sudo bash "$0" "$@"; }

################################################################################

readonly subcmd=${1:-"${builtin_subcmds[0]}"}; shift || :

for i in "${builtin_subcmds[@]}"; do
    [ "$i" != "$subcmd" ] || { "subcmd_$i" "$@"; exit; }
done
for i in "$basedir"/{overrides,sub,..}/"$subcmd.sh"; do
    [ -e "$i" ] || continue
    path=$(realpath "$i")
    # shellcheck disable=SC2093
    exec bash "$path" "$@"
done

echo "Invalid MotteKit subcommand: $subcmd. Run \"mottekit help\" for help" >&2
exit 1
