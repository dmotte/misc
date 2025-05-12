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
    echo "Installed at $basedir"
    echo
    echo '/!\ WARNING: this tool can potentially harm your system! Use it at' \
        'your own risk, and make sure you always understand what you are' \
        'doing before proceeding.'
    echo
    echo 'Available subcommands:'
    echo

    find_with_category() { find "${1:?}" -type f -name "${2:?}" \
        -printf "${3:?} %P\n"; }

    items=$(printf 'builtin %s\n' "${builtin_subcmds[@]}")

    if [ -e "$basedir/overrides" ]; then
        items+=$'\n'$(find_with_category "$basedir/overrides" '*.sh' overrides)
    fi

    for i in sub ..; do
        items+=$'\n'$(find_with_category "$basedir/$i" '*.sh' "$i")
    done

    echo "$items" | while read -r category subpath; do
        echo "- ($category) ${subpath%.*}"
    done
}
# shellcheck disable=SC2317
subcmd_help() { subcmd_info "$@"; }
# shellcheck disable=SC2317
subcmd_version() { subcmd_info "$@"; }

# shellcheck disable=SC2317
subcmd_update() {
    reporoot=$(git -C "$basedir" rev-parse --show-toplevel)
    reposdir=$(dirname "$reporoot")

    if [ -d "$reposdir/dmotte" ] && [ -d "$reposdir/dmotte.github.io" ]; then
        echo 'Updating all the repos'
        exec bash "$reporoot/scripts/github-bak-all-repos.sh" \
            users/dmotte "$reposdir"
    else
        echo 'Updating MotteKit'
        # We run the pull in a Bash process spawned with "exec" because this
        # script could be changed by it
        exec bash -ec "git -C ${reporoot@Q} pull"
    fi
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
