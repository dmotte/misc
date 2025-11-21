#!/bin/bash

set -e

ensure_defined() {
    for arg; do if [ -z "${!arg}" ]; then echo \
    "The $arg env var is not defined" >&2; return 1; fi; done
}

ensure_defined CICD_{GIT_REF,OUTPUT,SUMMARY,REPO_{OWNER,NAME}}

if [ -z "$CICD_SUMMARY_TITLE" ]; then
    export CICD_SUMMARY_TITLE='## &#x1F680; MkDocs GitHub Pages CI/CD summary'
fi
if [ -z "$MKDOCS_SITE_DIR" ]; then
    export MKDOCS_SITE_DIR=site # MkDocs default value
fi

echo "::group::$0: Preparation"
    sudo apt-get update; sudo apt-get install -y python3-pip python3-venv
    python3 -mvenv venv
    venv/bin/python3 -mpip install mkdocs

    python3 --version
    venv/bin/python3 -mpip show pip mkdocs

    echo "$CICD_SUMMARY_TITLE" | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Additional options"
    add_opts_all=()
    if [ -n "$MKDOCS_CONFIG_FILE" ]; then
        add_opts_all+=("-f$MKDOCS_CONFIG_FILE")
    fi

    add_opts_build=("-d$MKDOCS_SITE_DIR")

    {
        if [ ${#add_opts_all[@]} = 0 ]; then
            echo '- &#x1F527; Additional MkDocs options for all commands:' \
                '(_none_)'
        else
            echo '- &#x1F527; Additional MkDocs options for all commands:' \
                "\`${add_opts_all[*]@Q}\`"
        fi

        if [ ${#add_opts_build[@]} = 0 ]; then
            echo '- &#x1F527; Additional MkDocs options for build:' \
                '(_none_)'
        else
            echo '- &#x1F527; Additional MkDocs options for build:' \
                "\`${add_opts_build[*]@Q}\`"
        fi
    } | tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Dependencies"
    if [ "$MKDOCS_DEPS" = auto ]; then
        deps_mode=auto
        deps_lines=$(venv/bin/python3 -mmkdocs get-deps "${add_opts_all[@]}")
        deps_commas=$(echo "$deps_lines" | paste -sd,)
    elif [ -n "$MKDOCS_DEPS" ]; then
        deps_mode=manual
        deps_lines=$(echo "$MKDOCS_DEPS" | tr , '\n')
        deps_commas=$MKDOCS_DEPS
    fi

    if [ -n "$deps_mode" ]; then
        # shellcheck disable=SC2016
        echo "- &#x1F9EC; Dependencies (**$deps_mode**):" \
            "\`${deps_commas//,/'`, `'}\`" | tee -a "$CICD_SUMMARY"

        echo "$deps_lines" | xargs -rd\\n venv/bin/python3 -mpip install
    fi
echo '::endgroup::'

echo "::group::$0: Build"
    if [ -n "$MKDOCS_DOCS_SRC" ]; then
        ensure_defined MKDOCS_DOCS_DST

        real_src=$(realpath "$MKDOCS_DOCS_SRC")
        real_dst=$(realpath "$MKDOCS_DOCS_DST")
        {
            echo "- &#x1F4C1; Source docs directory: \`$real_src\`"
            echo "- &#x1F4C1; Destination docs directory: \`$real_dst\`"
        } | tee -a "$CICD_SUMMARY"

        mkdir -pv "$real_dst"

        if [ -n "$MKDOCS_DOCS_EXCLUDES" ]; then
            # shellcheck disable=SC2016
            echo '- &#x1F4C1; Excluded items:' \
                "\`${MKDOCS_DOCS_EXCLUDES//,/'`, `'}\`" | tee -a "$CICD_SUMMARY"

            real_excludes=$(echo "$MKDOCS_DOCS_EXCLUDES" | tr , '\n' |
                while IFS= read -r i; do realpath "$real_src/$i"; done)
            echo 'Excluded paths:'; echo "$real_excludes"
            mapfile -t args_excludes < <(echo "$real_excludes" |
                while IFS= read -r i; do echo \!; echo '-path'; echo "$i"; done)
        else
            echo 'Excluded paths: (none)'
            args_excludes=()
        fi

        items=$(find "$real_src" -mindepth 1 -maxdepth 1 "${args_excludes[@]}")
        echo "$items" | while IFS= read -r i; do
            echo "Copying $i into $real_dst"
            cp -Rt"$real_dst" "$i"
        done
    fi

    venv/bin/python3 -mmkdocs build -s \
        "${add_opts_all[@]}" "${add_opts_build[@]}"
echo '::endgroup::'

echo "::group::$0: Artifact (GitHub Pages)"
    # Fix permissions. See https://github.com/actions/upload-pages-artifact#example-permissions-fix-for-linux
    chmod -Rc +rX "$MKDOCS_SITE_DIR"

    echo "ghpages-artifact-path=$MKDOCS_SITE_DIR" | tee -a "$CICD_OUTPUT"

    echo "- &#x1F4E6; GitHub Pages artifact directory: \`$MKDOCS_SITE_DIR\`" |
        tee -a "$CICD_SUMMARY"
echo '::endgroup::'

echo "::group::$0: Deployment (GitHub Pages)"
    if [ "$CICD_GIT_REF" = 'refs/heads/main' ]; then
        echo 'ghpages-deploy=true' | tee -a "$CICD_OUTPUT"

        echo "- &#x1F30D; GitHub Pages website:" \
            "https://$CICD_REPO_OWNER.github.io/$CICD_REPO_NAME" |
            tee -a "$CICD_SUMMARY"
    else
        echo 'Will not deploy because the Git ref is not the main branch'
    fi
echo '::endgroup::'
