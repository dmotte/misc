#!/bin/bash

set -e

# This script spawns a Bash background process and exposes its
# streams (stdin and stdout+stderr) to a remote SSH server as a Unix socket.
# That's essentially exposing a reverse shell. Use with care!
# The "socat" utility is required on the SSH server

# Usage example:
#   REVSHELL_SSH=/c/Windows/System32/OpenSSH/ssh.exe \
#     bash revshell-ssh-socat.sh '$HOME/myshell.sock' myuser@192.168.0.123
# Then, on the remote server:
#   socat - UNIX-CONNECT:"$HOME/myshell.sock"

# Warning: some commands (e.g. even a simple "cat") can make your reverse
# shell unusable, as there's no way to send CTRL+C or anything like that. As a
# workaround, you can use a reverse shell to spawn another reverse shell as
# a Bash job (using the "... &" syntax) so, if anything ever happens to
# it, you have a way to terminate and restart it

# Tested in Git Bash on Windows 11

readonly remote_socket_path=${1:?}; shift

readonly ssh=${REVSHELL_SSH:-ssh}

# We don't use "xargs" here because we want to use Bash's builtin "kill"
trap 'builtin kill $(jobs -p) 2>/dev/null || :; wait' EXIT

coproc BGSHELL { while :; do bash; done 2>&1; }

# We don't use "exec" here because we may have jobs running in the
# background and we want the EXIT trap to run before exiting
# shellcheck disable=SC2029
"$ssh" "$@" "socat UNIX-LISTEN:$remote_socket_path,fork,unlink-early -" \
    <&"${BGSHELL[0]}" >&"${BGSHELL[1]}"
