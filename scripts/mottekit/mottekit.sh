#!/bin/bash

set -e

basedir=$(dirname "$0")

readonly builtin_subcmds=(info help version update source sudo)

# Prints all the subcommands in the format "category name"
# shellcheck disable=SC2317
print_subcmds() {
    printf 'builtin %s\n' "${builtin_subcmds[@]}"

    {
        if [ -e "$basedir/overrides" ]; then
            find "$basedir/overrides" -type f \
                \( -name '*.sh' -o -name '*.py' \) -printf "ovr %P\n"
        fi

        find "$basedir/sub" -type f \
            \( -name '*.sh' -o -name '*.py' \) -printf "sub %P\n"

        find "$basedir/.." -type f -name '*.sh' -printf ".. %P\n"

        find "$basedir/../../python-scripts" -mindepth 2 -maxdepth 2 \
            -type f -name '*.py' -printf "pyscr %P\n"
    } | while read -r category name; do
        case $name in
            */main.sh) name="${name%/main.sh}";;
            */main.py) name="${name%/main.py}";;
            *.sh) name="${name%.sh}";;
            *.py) name="${name%.py}";;
        esac

        echo "$category $name"
    done

    find "$basedir/../../.." -mindepth 3 -maxdepth 3 \
        -type f -name 'cli.py' -printf "pypkg %P\n" |
    while read -r category name; do
        name="${name%/cli.py}"

        echo "$category $name"
    done
}

# Prints the path of a subcommand's script file, or "builtin" if builtin, or
# "none" if not found
# shellcheck disable=SC2317
get_subcmd_path() {
    local name=${1:?}

    for i in "${builtin_subcmds[@]}"; do
        [ "$i" = "$name" ] || continue
        echo builtin; return
    done

    for i in \
        "$basedir/overrides/$name"{,/main}.{sh,py} \
        "$basedir/sub/$name"{,/main}.{sh,py} \
        "$basedir/../$name"{,/main}.sh \
        "$basedir/../../python-scripts/$name"{,/main}.py \
        "$basedir/../../../$name/cli.py" \
    ; do
        [ -e "$i" ] || continue
        echo "$i"; return
    done

    echo none
}

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
    print_subcmds | sed -E 's/^([^ ]+) (.+)$/- (\1) \2/'
}
# shellcheck disable=SC2317
subcmd_help() { subcmd_info "$@"; }
# shellcheck disable=SC2317
subcmd_version() { subcmd_info "$@"; }

# shellcheck disable=SC2317
subcmd_update() {
    local reporoot reposdir
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
    local name=${1:?}

    local path; path=$(get_subcmd_path "$name")

    [ "$path" != builtin ] ||
        { echo "Subcommand $name is builtin" >&2; exit 1; }
    [ "$path" != none ] ||
        { echo "Subcommand $name not found" >&2; exit 1; }

    exec cat "$path"
}

# shellcheck disable=SC2317
subcmd_sudo() { exec sudo bash "$0" "$@"; }

################################################################################

name=${1:-"${builtin_subcmds[0]}"}; shift || :

path=$(get_subcmd_path "$name")

[ "$path" != none ] || {
    echo "Invalid MotteKit subcommand: $name." \
        'Run "mottekit help" for help' >&2
    exit 1
}

[ "$path" != builtin ] || { "subcmd_$name" "$@"; exit; }

path=$(realpath "$path")

[[ "$path" = *.sh ]] && exec bash "$path" "$@"

if [[ "$(uname)" = MINGW* ]]; then py=python; else py=python3; fi
if [[ "$(uname)" = MINGW* ]]
    then venvpy=venv/Scripts/python
    else venvpy=venv/bin/python3
fi

[[ "$path" = */cli.py ]] && {
    [ -d "$basedir/venv" ] || {
        echo "Creating venv $basedir/venv" >&2
        "$py" -mvenv "$basedir/venv"
    }

    pkgpath=$(realpath "$(dirname "$path")/..")
    pkgname=$(basename "$pkgpath")
    entrypoint=$(basename "$(dirname "$path")")

    "$basedir/$venvpy" -mpip show "$pkgname" >/dev/null 2>&1 ||
        "$basedir/$venvpy" -mpip install -e "$pkgpath"

    exec "$basedir/$venvpy" -m"$entrypoint" "$@"
}
[[ "$path" = *.py ]] && {
    dirpath=$(realpath "$(dirname "$path")")

    if [ -e "$dirpath/requirements.txt" ] &&
        grep -Fx '/venv/' "$dirpath/.gitignore" >/dev/null 2>&1; then
        [ -d "$dirpath/venv" ] || {
            echo "Creating venv $dirpath/venv" >&2
            "$py" -mvenv "$dirpath/venv"

            "$dirpath/$venvpy" -mpip install -r "$dirpath/requirements.txt"
        }

        exec "$dirpath/$venvpy" "$path" "$@"
    else
        exec "$py" "$path" "$@"
    fi
}
