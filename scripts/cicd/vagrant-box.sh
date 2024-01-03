#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/helpers/version.sh"

ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined BOX_{AUTHOR,NAME,DESCRIPTION} CICD_{SECRET01,GIT_REF,SUMMARY}
vagrantcloud_token="$CICD_SECRET01"; unset CICD_SECRET01

if [ -z "$CICD_VERSION_EXPR" ]; then
    # shellcheck disable=SC2016
    export CICD_VERSION_EXPR='version_by_datetime $CICD_GIT_REF'
fi

echo "::group::$0: Preparation"
    echo '## &#x1F680; Vagrant box CI/CD summary' | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    {
        echo "- &#x1F9D1; Project author: \`$BOX_AUTHOR\`"
        echo "- &#x1F333; Project name: \`$BOX_NAME\`"
        echo "- &#x1F4CB; Project description: \`$BOX_DESCRIPTION\`"
    } | tee -a "$CICD_SUMMARY"

    echo "Version expression: $CICD_VERSION_EXPR"
    proj_ver="$(eval "$CICD_VERSION_EXPR")"
    {
        if [ -n "$proj_ver" ]; then
            echo "- &#x1F4CC; Project version: \`$proj_ver\`"
        else
            echo '- &#x1F4CC; Project version: (_none_)'
        fi
    } | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Build"
    if [ -n "$proj_ver" ]; then
        vagrant box update
        vagrant up --provision
        vagrant package # Creates the package.box file
        vagrant destroy -f
    else
        echo 'Not building the box because the version variable is empty or' \
            'not defined'
    fi
echo '::endgroup::'

echo "::group::$0: Release (Vagrant Cloud)"
    if [ -n "$proj_ver" ]; then
        vagrant cloud auth login --token "$vagrantcloud_token"

        version_description="$(
            echo -n 'This version has been released automatically with GitHub' \
                'Actions, commit '; git rev-parse --short HEAD
        )"
        vagrant cloud publish -s "$BOX_DESCRIPTION" \
            --version-description "$version_description" \
            --no-private --release --force \
            "$BOX_AUTHOR/$BOX_NAME" "${proj_ver#v}" virtualbox package.box

        link_release="https://app.vagrantup.com/$BOX_AUTHOR/boxes/$BOX_NAME/versions/${proj_ver#v}"
        echo '- &#x1F30D; Release on Vagrant Cloud:' \
            "[\`${proj_ver#v}\`]($link_release)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Not creating the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
