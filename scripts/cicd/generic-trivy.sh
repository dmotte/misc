#!/bin/bash

set -e

# shellcheck source=/dev/null
. "$(dirname "$0")/../../bash-libs/fetch-and-check.sh"

echo "::group::$0: Preparation"
    if ! command -v trivy; then
        # Source: https://trivy.dev/v0.59/getting-started/installation/#debianubuntu-official
        # See also the official Debian instructions to connect to a third-party
        # repository: https://wiki.debian.org/DebianRepository/UseThirdParty

        sudo apt-get update; sudo apt-get install -y gnupg

        cert=$(fetch_and_check \
            https://aquasecurity.github.io/trivy-repo/deb/public.key \
            51ca5d1384095c462099add67e46b028e0df0ff741c0f95ad30f561c4fad1ad4)
        echo "$cert" | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

        sudo tee /etc/apt/sources.list.d/trivy.sources << 'EOF'
Types: deb
URIs: https://aquasecurity.github.io/trivy-repo/deb
Suites: generic
Components: main
Signed-By: /usr/share/keyrings/trivy.gpg
EOF

        sudo apt-get update; sudo apt-get install -y trivy
    fi
    trivy --version
echo '::endgroup::'

trivy fs --exit-code=1 .
