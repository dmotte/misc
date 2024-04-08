#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../../bash-libs/fetch-and-check.sh"

codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)

echo "::group::$0: Preparation"
    if ! command -v trivy; then
        sudo apt-get update; sudo apt-get install -y gnupg
        fetch_and_check \
            'https://aquasecurity.github.io/trivy-repo/deb/public.key' \
            '51ca5d1384095c462099add67e46b028e0df0ff741c0f95ad30f561c4fad1ad4' |
            sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/trivy.gpg
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $codename main" |
            sudo tee /etc/apt/sources.list.d/trivy.list
        sudo apt-get update; sudo apt-get install -y trivy
    fi
    trivy --version
echo '::endgroup::'

trivy fs --exit-code=1 .
