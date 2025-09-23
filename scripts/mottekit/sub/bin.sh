#!/bin/bash

set -e

readonly username=dmotte

readonly name=${1:?}; shift

################################################################################

if [ "$BIN_UPDATE" != true ] && command -v "$name" >/dev/null; then
    [ "$BIN_NORUN" = true ] || exec "$name" "$@"
    echo "Command $name already installed"
    exit
fi

################################################################################

readonly path_dirs=(~/.local/bin ~/bin)

for i in "${path_dirs[@]}"; do
    [ "$PATH" = "$i" ] || [[ "$PATH" = *:"$i":* ]] ||
        [[ "$PATH" = "$i":* ]] || [[ "$PATH" = *:"$i" ]] &&
        { bin_path=$i/$name; break; }
done

[ -n "$bin_path" ] || {
    cat << EOF >&2
Cannot find a location in PATH suitable for installing the binary \
file. You must have one of the following directories in your PATH:
${path_dirs[*]@Q}
As a quick fix, you might possibly want to consider one of the following:
    echo 'export PATH="\$PATH:\$HOME/.local/bin"' >> ~/.bashrc
    echo 'export PATH="\$PATH:\$HOME/bin"' >> ~/.bashrc
And then close and reopen your terminal to update the value of the PATH \
environment variable.
Warning: please make sure you always understand what you are doing before \
proceeding.
EOF
    exit 1
}

################################################################################

target_triple=$(curl -fsSL https://sh.rustup.rs/ |
    RUSTUP_INIT_SH_PRINT=arch bash)

bin_url=https://github.com/$username/$name/releases/latest/download/$name-$target_triple

echo "Downloading $bin_url to $bin_path" >&2
curl -fLo "$bin_path" "$bin_url"
chmod +x "$bin_path"

[ "$BIN_NORUN" = true ] || exec "$name" "$@"
