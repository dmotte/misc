#!/bin/bash

set -e

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        sudo apt-get update
    fi
}
ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined CICD_{OUTPUT,SUMMARY}

echo "::group::$0: Preparation"
    if ! command -v cargo; then
        bash <(curl -fsSL https://sh.rustup.rs/) -y
        # shellcheck source=/dev/null
        . ~/.cargo/env
    fi
    rustc --version; cargo --version

    echo '## &#x1F680; Rust app CI/CD summary' | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    proj_name="$(sed -En 's/^name = "(.+)"$/\1/p' Cargo.toml | head -1)"
    echo "- &#x1F333; Project name: \`$proj_name\`" | \
        tee -a "$CICD_SUMMARY"

    proj_ver="${CICD_GIT_REF#refs/tags/}"
    [ "$proj_ver" != "$CICD_GIT_REF" ] || unset proj_ver
    {
        if [ -n "$proj_ver" ]; then
            echo "- &#x1F4CC; Project version: \`$proj_ver\`"
        else
            echo "- &#x1F4CC; Project version: (_none_)"
        fi
    } | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Format (cargo fmt)"
    cargo fmt --all --check
echo '::endgroup::'

echo "::group::$0: Lint (cargo clippy)"
    cargo clippy -- -D warnings -D clippy::pedantic
echo '::endgroup::'

echo "::group::$0: Update deps (cargo update)"
    cargo update --locked
echo '::endgroup::'

echo "::group::$0: Unit tests (cargo test)"
    cargo test --workspace
echo '::endgroup::'

echo "::group::$0: End-to-end tests (test/main.sh)"
    if [ -f test/main.sh ]; then
        bash test/main.sh
    else
        echo 'Not running end-to-end tests because test/main.sh does not exist'
    fi
echo '::endgroup::'

echo "::group::$0: Set the right version"
    if [ -n "$proj_ver" ]; then
        sed -i "s/^version = \"0.0.0\"$/version = \"${proj_ver#v}\"/" \
            Cargo.toml
    fi
    grep '^version = ' Cargo.toml
echo '::endgroup::'

echo "::group::$0: Build (cargo build)"
    sed -En 's/^\[target\.(.+)\]$/\1/p' .cargo/config.toml | \
        while read -r i; do
            case "$i" in
            aarch64-unknown-linux-gnu)
                apt_update_if_old
                sudo apt-get install -y gcc-aarch64-linux-gnu
                ;;
            i686-unknown-linux-gnu)
                apt_update_if_old
                sudo apt-get install -y gcc-i686-linux-gnu
                ;;
            x86_64-unknown-linux-gnu)
                apt_update_if_old
                sudo apt-get install -y gcc-x86-64-linux-gnu
                ;;
            esac

            rustup target add "$i"
            cargo build -r --target "$i"
        done
echo '::endgroup::'

echo "::group::$0: Artifact"
    mkdir -p cicd-artifact

    for src in target/*/release/"$proj_name"; do
        target="${src#target/}"
        target="${target%"/release/$proj_name"}"
        file_basename="$proj_name-$target"
        dst="cicd-artifact/$file_basename"

        echo "Copying $src to $dst"
        cp "$src" "$dst"
        echo "- &#x1F4E6; Artifact file: \`$file_basename\`" | \
            tee -a "$CICD_SUMMARY"
    done

    {
        echo 'artifact-name=artifact'
        echo 'artifact-path=cicd-artifact'
    } | tee -a "$CICD_OUTPUT"
echo '::endgroup::'

echo "::group::$0: Release (GitHub)"
    if [ -n "$proj_ver" ]; then
        {
            echo "release-name=$proj_ver"
            echo "release-files=cicd-artifact/*"
        } | tee -a "$CICD_OUTPUT"

        echo "- &#x1F6A2; Release name: \`$proj_ver\`" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
