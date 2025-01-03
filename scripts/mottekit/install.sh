#!/bin/bash

set -e

readonly mottekit_dir=~/.mottekit

[ -e "$mottekit_dir" ] &&
    { echo "The $mottekit_dir directory already exists" >&2; exit 1; }

path_dirs=(~/.local/bin ~/bin)

for i in "${path_dirs[@]}"; do
    [ "$PATH" = "$i" ] || [[ "$PATH" = *:"$i":* ]] ||
        [[ "$PATH" = "$i":* ]] || [[ "$PATH" = *:"$i" ]] &&
        { entrypoint=$i/mottekit; break; }
done

[ -z "$entrypoint" ] && {
    echo 'Cannot find a location in PATH suitable for installing the' \
        'MotteKit entrypoint. You must have one of the following' \
        'directories in your PATH:' >&2
    echo "${path_dirs[*]@Q}" >&2
    exit 1
}

[ -e "$entrypoint" ] &&
    { echo "The entrypoint $entrypoint already exists" >&2; exit 1; }

command -v git >/dev/null ||
    { echo 'The git command is required but cannot be found' >&2; exit 1; }

echo "Creating the MotteKit directory $mottekit_dir"
mkdir "$mottekit_dir"

readonly repo_url=https://github.com/dmotte/misc.git \
    repo_dir=$mottekit_dir/misc
echo "Cloning $repo_url into $repo_dir"
git clone "$repo_url" "$repo_dir"

readonly mottekit_script=$repo_dir/scripts/mottekit/mottekit.sh
echo "Creating MotteKit entrypoint at $entrypoint"
echo $'#!/bin/bash\nexec bash '"${mottekit_script@Q}"' "$@"' |
    install -Dm755 /dev/stdin "$entrypoint"
