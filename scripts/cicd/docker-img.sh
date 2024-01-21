#!/bin/bash

set -e

readonly TMP_IMG=tmp:latest

# shellcheck source=/dev/null
. "$(dirname "$0")/helpers/version.sh"

ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined DOCKERHUB_USERNAME IMG_{AUTHOR,NAME,PLATFORMS} \
    CICD_{SECRET01,GIT_REF,SUMMARY}
dockerhub_password="$CICD_SECRET01"; unset CICD_SECRET01

if [ -z "$CICD_VERSION_EXPR" ]; then
    # shellcheck disable=SC2016
    export CICD_VERSION_EXPR='version_by_datetime $CICD_GIT_REF'
fi
if [ -z "$CICD_SUMMARY_TITLE" ]; then
    # shellcheck disable=SC2016
    export CICD_SUMMARY_TITLE='## &#x1F680; Docker image CI/CD summary'
fi

echo "::group::$0: Preparation"
    sudo apt-get update; sudo apt-get install -y curl jq

    docker --version; docker info

    # The QEMU setup procedure is inspired by:
    # https://github.com/docker/setup-qemu-action/blob/master/src/main.ts
    docker run --rm --privileged docker.io/tonistiigi/binfmt:latest \
        --install "$IMG_PLATFORMS"

    echo "$CICD_SUMMARY_TITLE" | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Project metadata"
    {
        echo "- &#x1F9D1; Project author: \`$IMG_AUTHOR\`"
        echo "- &#x1F333; Project name: \`$IMG_NAME\`"

        # shellcheck disable=SC2016
        echo "- &#x1F5A5; Supported platforms: \`${IMG_PLATFORMS//,/'`, `'}\`"

        if [ -n "$IMG_DESCRIPTION" ]; then
            echo "- &#x1F4CB; Project description: \`$IMG_DESCRIPTION\`"
        else
            echo '- &#x1F4CB; Project description: (_none_)'
        fi
        if [ -n "$IMG_FULL_DESCRIPTION_FILE" ]; then
            echo '- &#x1F4CB; Project full description file:' \
                "\`$IMG_FULL_DESCRIPTION_FILE\`"
        else
            echo '- &#x1F4CB; Project full description file: (_none_)'
        fi
    } | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Preliminary build"
    docker build -t "$TMP_IMG" build/
echo '::endgroup::'

echo "::group::$0: Version"
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

echo "::group::$0: Docker tags"
    if [ -n "$proj_ver" ]; then
        docker_tags=$(echo latest; echo "$proj_ver" | tr . '\n' | {
            concat=''
            while read -r i; do
                concat="$concat$i."
                echo "${concat%?}"
            done
        })

        # shellcheck disable=SC2016
        echo "- &#x1F3F7; Docker tags: \`$(echo -n "$docker_tags" | \
            xargs | sed 's/ /`, `/g')\`" | tee -a "$CICD_SUMMARY"
    else
        echo 'Not generating the Docker tags because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'

echo "::group::$0: Build (Docker Buildx) + Release (Docker Hub)"
    if [ -n "$proj_ver" ]; then
        echo "$dockerhub_password" | docker login -u "$DOCKERHUB_USERNAME" \
            --password-stdin

        # The build command is inspired by:
        # https://github.com/docker/build-push-action/blob/master/src/main.ts
        # This builds the images for different platforms in parallel
        docker buildx create --use
        echo "$docker_tags" | while read -r i; do
            echo "--tag=docker.io/$IMG_AUTHOR/$IMG_NAME:$i"
        done | xargs -rd\\n docker buildx build --platform="$IMG_PLATFORMS" \
            --iidfile=buildx-image-id.txt --metadata-file=buildx-metadata.txt \
            --push build/
        docker buildx rm
        cat buildx-image-id.txt; echo; cat buildx-metadata.txt; echo

        link_release="https://hub.docker.com/r/$IMG_AUTHOR/$IMG_NAME/tags"
        echo '- &#x1F30D; Release on Docker Hub:' \
            "[\`${proj_ver#v}\`]($link_release)" | tee -a "$CICD_SUMMARY"
    else
        echo 'Not creating the release because the version variable is' \
            'empty or not defined'
    fi
echo '::endgroup::'

echo "::group::$0: Description (Docker Hub)"
    if [ -n "$proj_ver" ]; then
        if [ -n "$IMG_DESCRIPTION" ] && \
            [ -n "$IMG_FULL_DESCRIPTION_FILE" ]; then
            payload="{
                \"description\": $(echo -n "$IMG_DESCRIPTION" | jq -Rs .),
                \"full_description\": $(jq -Rs . < "$IMG_FULL_DESCRIPTION_FILE")
            }"
        elif [ -n "$IMG_DESCRIPTION" ]; then
            payload="{
                \"description\": $(echo -n "$IMG_DESCRIPTION" | jq -Rs .)
            }"
        elif [ -n "$IMG_FULL_DESCRIPTION_FILE" ]; then
            payload="{
                \"full_description\": $(jq -Rs . < "$IMG_FULL_DESCRIPTION_FILE")
            }"
        fi
        echo "Payload: $payload"

        if [ -n "$payload" ]; then
            response=$(curl -sSXPOST https://hub.docker.com/v2/users/login \
                -dusername="$DOCKERHUB_USERNAME" \
                -dpassword="$dockerhub_password" --fail-with-body) || {
                    echo 'Docker Hub login failed' >&2
                    echo "$response" >&2
                    exit 1
                }

            token=$(echo "$response" | sed -E 's/^\{"token":"([^"]+)"\}/\1/g')

            curl -sSXPATCH \
                "https://hub.docker.com/v2/repositories/$IMG_AUTHOR/$IMG_NAME" \
                -H 'Content-Type: application/json' \
                -H "Authorization: JWT $token" --fail-with-body -d "$payload"
        else
            echo 'Not setting the description on Docker Hub because both the' \
            'description variables are empty or not defined'
        fi
    else
        echo 'Not setting the description on Docker Hub because the version' \
            'variable is empty or not defined'
    fi
echo '::endgroup::'
