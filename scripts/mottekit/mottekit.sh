#!/bin/bash

set -e

basedir=$(dirname "$0")

readonly builtin_subcmds=(info help version update)

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
    echo 'Available subcommands:'
    echo
    for i in "${builtin_subcmds[@]}"; do
        echo "- (builtin) $i"
    done
    for i in "$basedir"/overrides/*.sh; do
        [ -e "$i" ] || continue
        echo "- (overrides) $(basename "${i%.sh}")"
    done
    for i in "$basedir"/sub/*.sh; do
        [ -e "$i" ] || continue
        echo "- (sub) $(basename "${i%.sh}")"
    done
    for i in "$basedir"/../*.sh; do
        [ -e "$i" ] || continue
        echo "- (..) $(basename "${i%.sh}")"
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
