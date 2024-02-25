#!/bin/bash

set -e

# This script copies a local directory onto a remote server and runs the
# main.sh script inside it

# Usage example:
#   RDR_REMOTE_TAR_OPTIONS=-v ./remote-dir-run.sh mydir \
#     ssh user@hostname -p2222

# Note: if you're using Git Bash on Windows, you may want to replace "ssh"
# with "/c/Windows/System32/OpenSSH/ssh.exe", or $GIT_SSH if you have it set.
# Or you can use ${GIT_SSH:-ssh} to cover both cases

[ $# -ge 2 ] || { echo 'Not enough args' >&2; exit 1; }
local_dir="$1"; shift

[ -e "$local_dir/main.sh" ] || { echo 'File main.sh not found' >&2; exit 1; }

: "${RDR_SHELL_OPTIONS:=-e}"
: "${RDR_CMD:=bash main.sh}"

remote_dir="/tmp/remote-dir-run-$(date -u +%Y-%m-%d-%H%M%S)"

cmd1=("$@")
cmd2=("$@")

{ read -rd '' script1 || [ -n "$script1" ]; } << EOF
set $RDR_SHELL_OPTIONS
rm -rf $remote_dir
mkdir $remote_dir
tar -xzf- -C$remote_dir --no-same-owner $RDR_REMOTE_TAR_OPTIONS
EOF

{ read -rd '' script2 || [ -n "$script2" ]; } << EOF
set $RDR_SHELL_OPTIONS
cd $remote_dir
$RDR_CMD || result=\$?
rm -rf $remote_dir
exit \${result:-0}
EOF

script1=$(echo "$script1" | tr \\n \;)
script2=$(echo "$script2" | tr \\n \;)

if [ -n "$RDR_ADD_CMD2_ARGS" ]; then
    while read -r i; do
        read -r str
        cmd2=("${cmd2[@]:0:$i}" "$str" "${cmd2[@]:$i}")
    done < <(echo "$RDR_ADD_CMD2_ARGS" | tr , '\n')
fi

if [ "$RDR_ESCAPE_SCRIPTS" = 'true' ]; then
    script1="${script1@Q}"
    script2="${script2@Q}"
fi

if [ -n "$RDR_EVAL" ]; then eval "$RDR_EVAL"; fi

# Operations are split in two separate connections because we want the
# "$local_dir/main.sh" script to be able to read from our end's stdin
# shellcheck disable=SC2086
tar -czf- -C"$local_dir" $RDR_LOCAL_TAR_OPTIONS . | "${cmd1[@]}" "$script1"
"${cmd2[@]}" "$script2"
