#!/bin/bash

set -e

basedir=$(dirname "$0")

echo "::group::$0: Preparation"
    if ! command -v trivy; then
        sudo bash "$basedir/../provisioning/apt-trivy.sh"
    fi
    trivy --version
echo '::endgroup::'

trivy fs --exit-code=1 .
