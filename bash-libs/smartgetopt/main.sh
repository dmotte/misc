#!/bin/bash

set -e

smartgetopt() {
    # The names of these nameref variables start with an underscore to avoid
    # circular references (see https://stackoverflow.com/a/33777659)
    declare -n _opts="$1" _so="$2" _rem="$3"; shift 3

    local arg_o=+
    for k in "${!_so[@]}"; do
        [ "${_opts[${_so[$k]}]?}" = n ] && arg_o+=$k || arg_o+=$k:
    done

    local getopt_args=(-o "$arg_o")
    for k in "${!_opts[@]}"; do
        [ "${_opts[$k]}" = n ] \
            && getopt_args+=(-l "$k") || getopt_args+=(-l "$k:")
    done

    local options; options=$(getopt "${getopt_args[@]}" -- "$@")
    eval "options=($options)"

    for ((i = 0; i < ${#options[@]}; i++)); do
        [ "${options[i]}" = -- ] && { ((i+=1)); break; }

        [[ "${options[i]}" = -? ]] && options[i]="--${_so[${options[i]#-}]:?}"

        if [[ "${_opts[${options[i]#--}]?}" = [ny] ]]
            then _opts[${options[i]#--}]=y
            else _opts[${options[i]#--}]="${options[i+1]}"; ((i+=1))
        fi
    done

    _rem=("${options[@]:i}")
}
