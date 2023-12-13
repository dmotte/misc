#!/bin/bash

set -e

echo "::group::$0: Secrets"
    if [ -z "$CICD_SECRET01" ]; then
        echo 'CICD_SECRET01 (pypi_api_token) is not defined' >&2
        exit 1
    fi
    pypi_api_token="$CICD_SECRET01"; unset CICD_SECRET01
echo '::endgroup::'

echo "::group::$0: Preparation"
    if [ ! -e "$CICD_OUTPUT" ]; then
        echo 'The CICD_OUTPUT file does not exist' >&2
        exit 1
    fi
    if [ ! -e "$CICD_SUMMARY" ]; then
        echo 'The CICD_SUMMARY file does not exist' >&2
        exit 1
    fi

    sudo apt-get update; sudo apt-get install -y python3-pip python3-venv
    python3 -m venv venv
    venv/bin/python3 -m pip install autopep8 pytest build twine

    python3 --version
    venv/bin/python3 -m pip show pip autopep8 pytest build twine

    echo '## &#x1F680; Python package CI/CD summary' | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    proj_name="$(sed -En 's/^name = (.+)$/\1/p' setup.cfg | head -1)"
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

echo "::group::$0: Install package in editable mode"
    venv/bin/python3 -m pip install -e .
echo '::endgroup::'

echo "::group::$0: Format (autopep8)"
    venv/bin/python3 -m autopep8 -aaadr --max-line-length=80 --exit-code \
        --exclude=venv .
    # venv/bin/python3 -m black -Sl80 --check .
echo '::endgroup::'

echo "::group::$0: Unit tests (pytest)"
    venv/bin/python3 -m pytest .
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

        echo "- &#x1F6A2; Release name: \`$proj_ver\`" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'

echo "::group::$0: Release (PyPI)"
    if [ -n "$proj_ver" ]; then
        venv/bin/python3 -m build
        TWINE_USERNAME=__token__ TWINE_PASSWORD="$pypi_api_token" \
            venv/bin/python3 -m twine upload dist/*

        link_pypi="https://pypi.org/project/$proj_name/${proj_ver#v}/"
        echo "- &#x1F30D; Release on PyPI: [\`${proj_ver#v}\`]($link_pypi)" | \
            tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
