#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/helpers/version.sh"

apt_update_if_old() {
    if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -mmin -60)" ]; then
        sudo apt-get update
    fi
}
ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined CICD_{GIT_REF,REPO_URL,OUTPUT,SUMMARY}

if [ -z "$CICD_VERSION_EXPR" ]; then
    export CICD_VERSION_EXPR="version_by_tag ${CICD_GIT_REF@Q}"
fi
if [ -z "$CICD_SUMMARY_TITLE" ]; then
    export CICD_SUMMARY_TITLE='## &#x1F680; Rust app CI/CD summary'
fi

echo "::group::$0: Preparation"
    if ! command -v cargo; then
        bash <(curl -fsSL https://sh.rustup.rs/) -y
        # shellcheck source=/dev/null
        . ~/.cargo/env
    fi
    rustc --version; cargo --version

    echo "$CICD_SUMMARY_TITLE" | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    proj_name=$(sed -En 's/^name = "(.+)"$/\1/p' Cargo.toml | head -n1)
    echo "- &#x1F333; Project name: \`$proj_name\`" |
        tee -a "$CICD_SUMMARY"

    echo "Version expression: $CICD_VERSION_EXPR"
    proj_ver=$(eval "$CICD_VERSION_EXPR")
    {
        if [ -n "$proj_ver" ]; then
            echo "- &#x1F4CC; Project version: \`$proj_ver\`"
        else
            echo '- &#x1F4CC; Project version: (_none_)'
        fi
    } | tee -a "$CICD_SUMMARY"

    build_targets=$(sed -En 's/^\[target\.(.+)\]$/\1/p' .cargo/config.toml)
    echo "Build targets:"; echo "$build_targets"
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
    if [ -e test/main.sh ]; then
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
    echo "$build_targets" | while IFS= read -r i; do
        case $i in
        aarch64-unknown-linux-gnu)
            apt_update_if_old
            sudo apt-get install -y gcc-aarch64-linux-gnu
            ;;
        armv7-unknown-linux-gnueabihf)
            apt_update_if_old
            sudo apt-get install -y gcc-arm-linux-gnueabihf
            ;;
        i686-pc-windows-gnu)
            apt_update_if_old
            sudo apt-get install -y gcc-mingw-w64-i686
            ;;
        i686-unknown-linux-gnu)
            apt_update_if_old
            sudo apt-get install -y gcc-i686-linux-gnu
            ;;
        x86_64-pc-windows-gnu)
            apt_update_if_old
            sudo apt-get install -y gcc-mingw-w64-x86-64
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
    mkdir -pv cicd-artifact

    echo "$build_targets" | while IFS= read -r i; do
        src=target/$i/release/$proj_name
        [[ "$i" = *-pc-windows-* ]] && src+=.exe
        file_basename=$proj_name-$i
        [[ "$i" = *-pc-windows-* ]] && file_basename+=.exe
        dst=cicd-artifact/$file_basename

        cp -Tv "$src" "$dst"
        echo "- &#x1F4E6; Artifact file: \`$file_basename\`" |
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
            echo 'release-files=cicd-artifact/*'
        } | tee -a "$CICD_OUTPUT"

        link_release=$CICD_REPO_URL/releases/tag/$proj_ver
        echo '- &#x1F6A2; Release on GitHub:' \
            "[\`$proj_ver\`]($link_release)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
