#!/bin/bash

set -e

# This script should be run automatically by the CI/CD

# Ensure that some variables are defined
: "${MISC_SCRIPTS_DIR:?}"

cd "$(dirname "$0")"

website_deployment_info='## Deployment info\n\n'
website_deployment_info+=":rocket: Last website deployment on _$(date -u)_."

sed -i "/<!-- WEBSITE DEPLOYMENT INFO -->/c\\$website_deployment_info" README.md

export MKDOCS_DEPS=mkdocs-material,mkdocs-minify-plugin,pymdown-extensions
export MKDOCS_DOCS_SRC=. MKDOCS_DOCS_DST=mkdocs-docs
export MKDOCS_DOCS_EXCLUDES=.git,venv,mkdocs-docs,mkdocs-site
export MKDOCS_SITE_DIR=mkdocs-site

exec bash "$(realpath "$MISC_SCRIPTS_DIR/cicd/mkdocs-ghpages.sh")"
