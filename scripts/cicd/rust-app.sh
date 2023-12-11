#!/bin/bash

set -e

echo "::group::$0: Preparation"
    if [ ! -e "$CICD_OUTPUT" ]; then
        echo 'The CICD_OUTPUT file does not exist' >&2
        exit 1
    fi
    if [ ! -e "$CICD_SUMMARY" ]; then
        echo 'The CICD_SUMMARY file does not exist' >&2
        exit 1
    fi

    if ! command -v cargo; then
        bash <(curl -fsSL https://sh.rustup.rs/) -y
        # shellcheck source=/dev/null
        . ~/.cargo/env
    fi
    rustc --version; cargo --version

    echo '## :rocket: Rust app CI/CD summary' | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    proj_name="$(sed -En 's/^name = "(.+)"$/\1/p' Cargo.toml | head -1)"
    echo "- :deciduous_tree: Project name: \`$proj_name\`" | \
        tee -a "$CICD_SUMMARY"

    proj_ver="${CICD_GIT_REF#refs/tags/}"
    [ "$proj_ver" != "$CICD_GIT_REF" ] || unset proj_ver
    {
        if [ -n "$proj_ver" ]; then
            echo "- :pushpin: Project version: \`$proj_ver\`"
        else
            echo "- :pushpin: Project version: (_none_)"
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

echo "::group::$0: Build (cargo build)"
    if [ -n "$proj_ver" ]; then
        sed -i "s/^version = \"0.0.0\"$/version = \"${proj_ver#v}\"/" \
            Cargo.toml
    fi

    sed -En 's/^\[target\.(.+)\]$/\1/p' .cargo/config.toml | \
        while read -r i; do
            case "$i" in
            aarch64-unknown-linux-gnu)
                sudo apt-get update
                sudo apt-get install -y gcc-aarch64-linux-gnu
                ;;
            i686-unknown-linux-gnu)
                sudo apt-get update
                sudo apt-get install -y gcc-i686-linux-gnu
                ;;
            x86_64-unknown-linux-gnu)
                sudo apt-get update
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
        echo "- :package: Artifact file: \`$file_basename\`" | \
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

        echo "- :ship: Release name: \`$proj_ver\`" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
