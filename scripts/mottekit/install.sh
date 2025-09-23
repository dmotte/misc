#!/bin/bash

set -e

readonly repos_dir=${1:-~/.ghdmotte}

# Note: jq is required by github-bak-all-repos.sh
for i in curl git jq; do
    command -v "$i" >/dev/null || { echo "Command $i not found" >&2; exit 1; }
done

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

if [ "$MOTTEKIT_INSTALL_OVERWRITE" != true ] && [ -e "$entrypoint" ]; then
    cat << EOF >&2
The entrypoint $entrypoint already exists.
This may mean that MotteKit is already installed. If so, you can use \
"mottekit update" to update it.
Alternatively, set the MOTTEKIT_INSTALL_OVERWRITE environment variable to \
"true" to ignore this check.
EOF
    exit 1
fi

################################################################################

readonly misc_repo_url=https://github.com/dmotte/misc.git
readonly misc_repo_path=$repos_dir/misc
if [ -d "$misc_repo_path" ]; then
    echo "Pulling repo $misc_repo_path"
    git -C "$misc_repo_path" pull
else
    echo "Cloning $misc_repo_url into $misc_repo_path"
    git clone "$misc_repo_url" "$misc_repo_path"
fi

readonly github_owner=users/dmotte
if [ "$MOTTEKIT_INSTALL_ONLY_MISC" != true ]; then
    echo "Getting all the other repos from GitHub owner $github_owner" \
        "to $repos_dir"
    bash "$misc_repo_path/scripts/github-bak-all-repos.sh" \
        "$github_owner" "$repos_dir"
fi

readonly mottekit_script=$misc_repo_path/scripts/mottekit/mottekit.sh
echo "Creating entrypoint at $entrypoint that invokes $mottekit_script"
echo $'#!/bin/bash\nexec bash '"${mottekit_script@Q}"' "$@"' |
    install -DT /dev/stdin "$entrypoint"
