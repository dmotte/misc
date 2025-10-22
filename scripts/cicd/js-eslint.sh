#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../../bash-libs/fetch-and-check.sh"

readonly toolchain_dir=/tmp/toolchain-eslint
readonly eslint_config_mjs='import globals from "globals";
import html from "eslint-plugin-html";
import js from "@eslint/js";

export default [
  { files: ["**/*.html"], plugins: { html } },
  { languageOptions: { globals: globals.browser } },
  js.configs.all,
];'

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

    if [ ! -d "$toolchain_dir" ]; then
        mkdir -v "$toolchain_dir"
        ( # Subshell
            cd "$toolchain_dir"
            npm init -y
            npm install eslint @eslint/js eslint-plugin-html globals
        )
    fi
    "$toolchain_dir/node_modules/.bin/eslint" --version

    echo "$eslint_config_mjs" | tee "$toolchain_dir/eslint.config.mjs"
echo '::endgroup::'

"$toolchain_dir/node_modules/.bin/eslint" \
    --config="$toolchain_dir/eslint.config.mjs" \
    .
