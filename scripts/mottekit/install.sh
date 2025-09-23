#!/bin/bash

set -e

misc_repo_path=$1

if [ -n "$misc_repo_path" ]; then
    misc_repo_path=$(realpath "$misc_repo_path")

    [ -d "$misc_repo_path" ] ||
        { echo "Dir $misc_repo_path not found" >&2; exit 1; }
else
    readonly mottekit_dir=~/.mottekit

    [ -e "$mottekit_dir" ] &&
        { echo "The $mottekit_dir directory already exists" >&2; exit 1; }
fi

readonly path_dirs=(~/.local/bin ~/bin)

for i in "${path_dirs[@]}"; do
    [ "$PATH" = "$i" ] || [[ "$PATH" = *:"$i":* ]] ||
        [[ "$PATH" = "$i":* ]] || [[ "$PATH" = *:"$i" ]] &&
        { entrypoint=$i/mottekit; break; }
done

[ -n "$entrypoint" ] || {
    cat << EOF >&2
Cannot find a location in PATH suitable for installing the MotteKit \
entrypoint. You must have one of the following directories in your PATH:
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

[ -e "$entrypoint" ] &&
    { echo "The entrypoint $entrypoint already exists" >&2; exit 1; }

command -v git >/dev/null ||
    { echo 'The git command is required but cannot be found' >&2; exit 1; }

if [ -z "$misc_repo_path" ]; then
    echo "Creating the MotteKit directory $mottekit_dir"
    mkdir "$mottekit_dir"

    readonly misc_repo_url=https://github.com/dmotte/misc.git
    misc_repo_path=$mottekit_dir/misc
    echo "Cloning $misc_repo_url into $misc_repo_path"
    git clone "$misc_repo_url" "$misc_repo_path"
fi

readonly mottekit_script=$misc_repo_path/scripts/mottekit/mottekit.sh
echo "Creating entrypoint at $entrypoint that invokes $mottekit_script"
echo $'#!/bin/bash\nexec bash '"${mottekit_script@Q}"' "$@"' |
    install -DT /dev/stdin "$entrypoint"
