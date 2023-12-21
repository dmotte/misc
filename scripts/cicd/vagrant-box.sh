#!/bin/bash

set -e

if [ -z "$BOX_AUTHOR" ]; then
    echo 'BOX_AUTHOR is not defined' >&2
    exit 1
fi
if [ -z "$BOX_NAME" ]; then
    echo 'BOX_NAME is not defined' >&2
    exit 1
fi
if [ -z "$BOX_DESCRIPTION" ]; then
    echo 'BOX_DESCRIPTION is not defined' >&2
    exit 1
fi

if [ -z "$CICD_SECRET01" ]; then
    echo 'CICD_SECRET01 (vagrantcloud_token) is not defined' >&2
    exit 1
fi
vagrantcloud_token="$CICD_SECRET01"; unset CICD_SECRET01

echo "::group::$0: Preparation"
    if [ ! -e "$CICD_OUTPUT" ]; then
        echo 'The CICD_OUTPUT file does not exist' >&2
        exit 1
    fi
    if [ ! -e "$CICD_SUMMARY" ]; then
        echo 'The CICD_SUMMARY file does not exist' >&2
        exit 1
    fi

    echo '## &#x1F680; Vagrant box CI/CD summary' | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    echo "- &#x1F9D1; Project author: \`$BOX_AUTHOR\`" | tee -a "$CICD_SUMMARY"
    echo "- &#x1F333; Project name: \`$BOX_NAME\`" | tee -a "$CICD_SUMMARY"
    echo "- &#x1F4CB; Project description: \`$BOX_DESCRIPTION\`" | \
        tee -a "$CICD_SUMMARY"

    if [ "$CICD_GIT_REF" = 'refs/heads/main' ]; then
        proj_ver="v$(date +%Y.%m.%d.%H%M)"
    fi
    {
        if [ -n "$proj_ver" ]; then
            echo "- &#x1F4CC; Project version: \`$proj_ver\`"
        else
            echo "- &#x1F4CC; Project version: (_none_)"
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
            echo -n "This version has been released automatically with GitHub" \
                "Actions, commit "; git rev-parse --short HEAD
        )"
        echo "TODO $version_description"
        vagrant cloud publish -s "$BOX_DESCRIPTION" \
            --version-description "$version_description" \
            --no-private --release --force \
            "$BOX_AUTHOR/$BOX_NAME" "${proj_ver#v}" virtualbox package.box

        link_vagrantcloud="https://app.vagrantup.com/$BOX_AUTHOR/boxes/$BOX_NAME/versions/${proj_ver#v}"
        echo "- &#x1F30D; Release on Vagrant Cloud:" \
            "[\`${proj_ver#v}\`]($link_vagrantcloud)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Will not create the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'
