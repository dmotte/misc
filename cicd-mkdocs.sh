#!/bin/bash

set -e

# Ensure that some variables are defined
: "${MISC_SCRIPTS_DIR:?}"

cd "$(dirname "$0")"

export MKDOCS_DEPS=mkdocs-material,mkdocs-minify-plugin,pymdown-extensions
export MKDOCS_DOCS_SRC=. MKDOCS_DOCS_DST=mkdocs-docs
export MKDOCS_DOCS_EXCLUDES=.git,venv,mkdocs-docs,mkdocs-site
export MKDOCS_SITE_DIR=mkdocs-site

exec bash "$(realpath "$MISC_SCRIPTS_DIR/cicd/mkdocs-ghpages.sh")"
