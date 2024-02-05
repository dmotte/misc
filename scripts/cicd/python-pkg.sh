#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/helpers/version.sh"

ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined CICD_{SECRET01,GIT_REF,REPO_URL,OUTPUT,SUMMARY}
pypi_api_token="$CICD_SECRET01"; unset CICD_SECRET01

if [ -z "$CICD_VERSION_EXPR" ]; then
    # shellcheck disable=SC2016
    export CICD_VERSION_EXPR='version_by_tag $CICD_GIT_REF'
fi
if [ -z "$CICD_SUMMARY_TITLE" ]; then
    export CICD_SUMMARY_TITLE='## &#x1F680; Python package CI/CD summary'
fi

echo "::group::$0: Preparation"
    sudo apt-get update; sudo apt-get install -y python3-pip python3-venv
    python3 -mvenv venv
    venv/bin/python3 -mpip install autopep8 pytest build twine

    python3 --version
    venv/bin/python3 -mpip show pip autopep8 pytest build twine

    echo "$CICD_SUMMARY_TITLE" | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    proj_name=$(sed -En 's/^name = (.+)$/\1/p' setup.cfg | head -1)
    echo "- &#x1F333; Project name: \`$proj_name\`" | \
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
echo '::endgroup::'

echo "::group::$0: Install package in editable mode" # Needed for the next steps
    venv/bin/python3 -mpip install -e .
echo '::endgroup::'

echo "::group::$0: Format (autopep8)"
    venv/bin/python3 -mautopep8 -aaadr --max-line-length=80 --exit-code \
        --exclude=venv .
    # venv/bin/python3 -mblack -Sl80 --check .
echo '::endgroup::'

echo "::group::$0: Unit tests (pytest)"
    if [ -e test ]; then
        venv/bin/python3 -mpytest test
    else
        echo 'No tests to run'
    fi
echo '::endgroup::'

echo "::group::$0: Set the right version"
    if [ -n "$proj_ver" ]; then
        sed -i "s/^version = 0.0.0$/version = ${proj_ver#v}/" setup.cfg
    fi
    grep '^version = ' setup.cfg
echo '::endgroup::'

echo "::group::$0: Release (GitHub)"
    if [ -n "$proj_ver" ]; then
        echo "release-name=$proj_ver" | tee -a "$CICD_OUTPUT"

        link_release="$CICD_REPO_URL/releases/tag/$proj_ver"
        echo '- &#x1F6A2; Release on GitHub:' \
            "[\`$proj_ver\`]($link_release)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'

echo "::group::$0: Release (PyPI)"
    if [ -n "$proj_ver" ]; then
        venv/bin/python3 -mbuild
        TWINE_USERNAME=__token__ TWINE_PASSWORD="$pypi_api_token" \
            venv/bin/python3 -mtwine upload dist/*

        link_release="https://pypi.org/project/$proj_name/${proj_ver#v}/"
        echo '- &#x1F30D; Release on PyPI:' \
            "[\`${proj_ver#v}\`]($link_release)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Not creating the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
