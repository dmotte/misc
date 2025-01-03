#!/bin/bash

set -e

# Example of how to use "getopt" in Bash (which, keep in mind, is not the
# "getopts" builtin)

# Tested on Debian 12 (bookworm)

# Inspired by https://gist.github.com/drmalex07/6bcd65a0861f58b646a0

# Note: the plus ("+") character at the beginning of the shortopts string is to
# make "getopt" interpret the remainder parameters as non-option parameters as
# soon as the first non-option parameter is found (a.k.a. "posixly-correct"
# mode)

# Note: instead of "-l along,blong,clong:,dlong:" it's also possible to write
# "-l along -l blong -l clong: -l dlong:"

# See the "getopt" man page (https://linux.die.net/man/1/getopt) for more info

# If your script has a lot of options, you may want to use a helper like
# https://github.com/dmotte/misc/tree/main/bash-libs/smartgetopt

options=$(getopt -o +abc:d: -l along,blong,clong:,dlong: -- "$@")
eval "set -- $options"

flag_a=n # Boolean flag
flag_b=n
arg_c='' # This arg defaults to empty string
arg_d=${ARG_D:-default value} # This can also be set with an env var

while :; do
    case $1 in
        -a|--along) flag_a=y;;
        -b|--blong) flag_b=y;;
        -c|--clong) shift; arg_c=$1;;
        -d|--dlong) shift; arg_d=$1;;
        --) shift; break;;
    esac
    shift
done

echo "x-$flag_a-$flag_b-$arg_c-$arg_d-x"
echo "$@"
