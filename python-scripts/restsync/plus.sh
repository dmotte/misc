#!/bin/bash

set -e

readonly metadata_dir=${1:?}; shift

basedir=$(dirname "$0")

readonly restsync_main_py=$basedir/main.py
[ -f "$restsync_main_py" ] ||
    { echo "Script $restsync_main_py not found" >&2; exit 1; }

################################################################################

sftp_url=$(<"$metadata_dir/sftp-url.txt")

readonly restic_psw_asc=$metadata_dir/restic-psw.asc
[ -f "$restic_psw_asc" ] ||
    { echo "File $restic_psw_asc not found" >&2; exit 1; }

data_dir=$(<"$metadata_dir/data-dir.txt")
[[ "$data_dir" = /* ]] || data_dir=$metadata_dir/$data_dir

readonly state_yml=$metadata_dir/state.yml

################################################################################

readonly sys32=/c/Windows/System32

if [[ "$(uname)" = MINGW* ]] && [ -f "$sys32/OpenSSH/ssh.exe" ]; then
    ssh_cmd=$(cygpath -m "$sys32/OpenSSH/ssh.exe")
elif fullpath=$(command -v ssha); then
    if [ "$(head -c2 "$fullpath")" = '#!' ]
        then ssh_cmd="bash ${fullpath@Q}"
        else ssh_cmd=ssha
    fi
fi
if [[ "$(uname)" = MINGW* ]] && [ -f "$sys32/OpenSSH/sftp.exe" ]; then
    sftp_cmd=$(cygpath -m "$sys32/OpenSSH/sftp.exe")
elif fullpath=$(command -v sftpa); then
    if [ "$(head -c2 "$fullpath")" = '#!' ]
        then sftp_cmd="bash ${fullpath@Q}"
        else sftp_cmd=sftpa
    fi
fi

################################################################################

if [[ "$(uname)" = MINGW* ]]
    then if command -v winpty >/dev/null && [ -t 0 ] && [ -t 1 ]
        then readonly py=(winpty python)
        else readonly py=(python)
    fi
    else readonly py=(python3)
fi

################################################################################

restsync_args=(-u"$sftp_url" -d"$data_dir" -s"$state_yml")

[[ "$(uname)" = MINGW* ]] || restsync_args+=(-m)

if [ $# = 0 ]
    then restsync_args+=(repl)
    else restsync_args+=("$@")
fi

################################################################################

export RESTSYNC_PSW_CMD="gpg -dq --no-symkey-cache ${restic_psw_asc@Q}" \
    RESTSYNC_SSH_CMD=$ssh_cmd RESTSYNC_SFTP_CMD=$sftp_cmd

if command -v gnome-session-inhibit >/dev/null; then
    exec gnome-session-inhibit --app-id org.gnome.Terminal.desktop \
        --reason 'Restsync is running' --inhibit logout:suspend \
        "${py[@]}" "$restsync_main_py" "${restsync_args[@]}"
else
    exec "${py[@]}" "$restsync_main_py" "${restsync_args[@]}"
fi
