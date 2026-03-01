#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../../bash-libs/fetch-and-check.sh"

echo "::group::$0: Preparation"
    if ! command -v npm; then
        bash <(fetch_and_check \
            'https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh' \
            '2d8359a64a3cb07c02389ad88ceecd43f2fa469c06104f92f98df5b6f315275f')
        # shellcheck source=/dev/null
        . ~/.nvm/nvm.sh
        nvm install --lts
    fi
    npm --version

    npm install -g prettier
    npx prettier --version
echo '::endgroup::'

[ "$NESTED_IGNORE_FILES" = true ] || exec npx prettier -c .

# We needed to implement this custom logic because Prettier doesn't consider
# ignore files in subdirectories. See
# https://github.com/prettier/prettier/issues/4081#issuecomment-3980455396
# for more info.
# We have to actually rewrite all the patterns and we cannot simply rely on
# passing multiple "--ignore-path" options to Prettier because, in such case,
# if a pattern like "*.json" is present in ANY of the ignore files at any
# depth, then Prettier would ignore all such files AT ANY DEPTH, even outside
# the directory where the ignore file was found

if [ "$USE_GIT_LS_FILES" = true ]
    then ignfiles=$(git ls-files '.gitignore' '*/.gitignore' \
        '.prettierignore' '*/.prettierignore')
    else ignfiles=$(find . -type f \
        \( -name .gitignore -o -name .prettierignore \) -printf '%P\n')
fi

readonly combfile=.combined.prettierignore
[ ! -e "$combfile" ] || { echo "File $combfile already exists" >&2; exit 1; }
:> "$combfile" # Empty file
trap 'rm -v "$combfile"' EXIT

echo "$ignfiles" | while IFS= read -r ignfile; do
    dn=${ignfile%/*}
    # We use "$(<...)" here to remove all trailing newlines
    [ "$dn" != "$ignfile" ] || { echo "$(<"$ignfile")"; continue; }

    while IFS= read -r line || [ -n "$line" ]; do
        if [ -z "$line" ] || [[ "$line" = \#* ]]; then continue; fi

        # Rewrite the pattern based on official gitignore specification
        # https://git-scm.com/docs/gitignore#_pattern_format

        prefix=''; pattern=$line

        [[ "$pattern" != \!* ]] || { prefix=\!; pattern=${pattern:1}; }

        if [[ "$pattern" = /* ]]; then
            echo "$prefix$dn$pattern"
        elif [[ "$pattern" =~ /[^/] ]]; then
            echo "$prefix$dn/$pattern"
        else
            echo "$prefix$dn/**/$pattern"
        fi
    done < "$ignfile"
done > "$combfile"

# We cannot use "exec" here because we want to run the EXIT trap before
# exiting.
# We cannot use "--ignore-path=<(echo ...)" here because Prettier evaluates
# ignore files relatively to their path. That's a reason why we need a
# dedicated "$combfile" stored in proper location
npx prettier --ignore-path="$combfile" -c .
