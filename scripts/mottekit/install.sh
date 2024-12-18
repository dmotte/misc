#!/bin/bash

set -e

readonly mottekit_dir=~/.mottekit

[ -e "$mottekit_dir" ] &&
    { echo "The $mottekit_dir directory already exists" >&2; exit 1; }

for i in ~/.local/bin ~/bin; do
    [ "$PATH" = "$i" ] || [[ "$PATH" = *:"$i":* ]] ||
        [[ "$PATH" = "$i":* ]] || [[ "$PATH" = *:"$i" ]] &&
        { entrypoint=$i/mottekit; break; }
done

[ -z "$entrypoint" ] && {
    echo 'Cannot find a location in PATH suitable for installing the' \
        'MotteKit entrypoint' >&2
    exit 1
}

[ -e "$entrypoint" ] &&
    { echo "The entrypoint $entrypoint already exists" >&2; exit 1; }

echo "Creating the MotteKit directory $mottekit_dir"
mkdir "$mottekit_dir"

readonly repo_url=https://github.com/dmotte/misc.git \
    repo_dir=$mottekit_dir/misc
echo "Cloning $repo_url into $repo_dir"
git clone "$repo_url" "$repo_dir"

readonly mottekit_script=$repo_dir/scripts/mottekit/mottekit.sh
echo "Creating MotteKit entrypoint at $entrypoint"
echo $'#!/bin/bash\nexec bash '"${mottekit_script@Q}"' "$@"' |
    install -m755 /dev/stdin "$entrypoint"
