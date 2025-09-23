#!/bin/bash

set -e

readonly repos_dir=${1:-~/.ghdmotte}

command -v git >/dev/null ||
    { echo 'The git command is required but cannot be found' >&2; exit 1; }

################################################################################

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

[ -e "$entrypoint" ] && {
    cat << EOF >&2
The entrypoint $entrypoint already exists.
This may mean that MotteKit is already installed. If so, you can use \
"mottekit update" to update it.
EOF
    exit 1
}

################################################################################

readonly misc_repo_url=https://github.com/dmotte/misc.git
readonly misc_repo_path=$repos_dir/misc
echo "Cloning $misc_repo_url into $misc_repo_path"
git clone "$misc_repo_url" "$misc_repo_path"

readonly github_owner=users/dmotte
echo "Cloning all the other repos from GitHub owner $github_owner"
bash "$misc_repo_path/scripts/github-bak-all-repos.sh" \
    "$github_owner" "$repos_dir"

readonly mottekit_script=$misc_repo_path/scripts/mottekit/mottekit.sh
echo "Creating entrypoint at $entrypoint that invokes $mottekit_script"
echo $'#!/bin/bash\nexec bash '"${mottekit_script@Q}"' "$@"' |
    install -DT /dev/stdin "$entrypoint"
