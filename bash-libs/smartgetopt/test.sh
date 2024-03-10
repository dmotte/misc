#!/bin/bash

set -e

# To run the tests:
#   time test.sh; echo $?

cd "$(dirname "$0")"

# shellcheck source=/dev/null
. main.sh

run_test() {
    # shellcheck disable=SC2034
    declare -n ref_opts="$1" ref_shortopts="$2"; local expected="$3"; shift 3
    local remainder=()

    local result=0
    smartgetopt ref_opts ref_shortopts remainder "$@" || result=$?

    local actual; actual=$(
        for k in "${!ref_opts[@]}"; do
            echo "opt: $k: ${ref_opts[$k]@Q}"
        done | LC_ALL=C sort
        for r in "${remainder[@]}"; do echo "rem: ${r@Q}"; done
        echo "result: $result"
    )

    diff <(echo "$actual") <(echo "$expected")
}

case_id=0

################################################################################

echo "Test case $((++case_id))"

# shellcheck disable=SC2034
declare -A opts=([create]=n [refresh]=n [name]='' [path]=/) \
    shortopts=([r]=refresh [n]=name)
{ read -rd '' expected || [ -n "$expected" ]; } << 'EOF'
opt: create: 'n'
opt: name: ''
opt: path: '/'
opt: refresh: 'n'
result: 0
EOF
run_test opts shortopts "$expected"

echo "Test case $((++case_id))"

# shellcheck disable=SC2034
declare -A opts=([create]=n [refresh]=n [name]='' [path]=/) \
    shortopts=([r]=refresh [n]=name)
{ read -rd '' expected || [ -n "$expected" ]; } << 'EOF'
opt: create: 'n'
opt: name: ''
opt: path: '/'
opt: refresh: 'y'
result: 0
EOF
run_test opts shortopts "$expected" -r
