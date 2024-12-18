#!/bin/bash

set -e

readonly path_mottekit=~/.mottekit

[ "$MOTTEKIT_TESTING" = true ] || { echo 'TODO test this script' >&2; exit 1; }

[ -e "$path_mottekit" ] &&
    { echo "The $path_mottekit directory already exists" >&2; exit 1; }

for i in ~/.local/bin ~/bin; do
    [ "$PATH" = "$i" ] || [[ "$PATH" = *:"$i":* ]] ||
        [[ "$PATH" = "$i":* ]] || [[ "$PATH" = *:"$i" ]] &&
        { path_entrypoint="$i/mottekit"; break; }
done

[ -z "$path_entrypoint" ] && {
    echo 'Cannot find a valid location in PATH to install the MotteKit' \
        'entrypoint' >&2
    exit 1
}

[ -e "$path_entrypoint" ] &&
    { echo "The entrypoint $path_entrypoint already exists" >&2; exit 1; }

echo "Creating MotteKit directory $path_mottekit"
mkdir "$path_mottekit"

echo "Cloning MotteKit repo into $path_mottekit/misc"
git clone https://github.com/dmotte/misc.git "$path_mottekit/misc"

echo "Creating MotteKit entrypoint $path_entrypoint"
readonly path_mottekit_script=$path_mottekit/misc/scripts/mottekit/mottekit.sh
echo $'#!/bin/bash\nexec bash '"${path_mottekit_script@Q}"' "$@"' |
    install -m755 /dev/stdin "$path_entrypoint"
