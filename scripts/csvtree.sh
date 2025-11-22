#!/bin/bash

set -e

# This script can be used to generate a CSV tree of a specific directory,
# optionally including hashes (checksums) for all the files

# Note: the semicolon character (";") is used as field separator, as it is
# normally not used in filenames

# Note: the output should be somehow similar to "rclone lsf -R --format=psth"

# Usage examples:
#   bash csvtree.sh mydir -mindepth 1 \! -name myexclude.txt > tree-mydir.csv
#   CSVTREE_HASH_FUNC=md5 bash csvtree.sh mydir < old.csv > tree-mydir.csv
#   CSVTREE_HASH_FUNC=md5 bash csvtree.sh mydir </dev/null > tree-mydir.csv

readonly main_dir=${1:?}; shift
readonly add_find_args=("$@")

readonly hash_func=$CSVTREE_HASH_FUNC

################################################################################

tree=$(find "$main_dir" "${add_find_args[@]}" \( \
    \( -type d -printf '%P/;%#m;-1;DIR\n' \) \
    -o \( -type f -printf '%P;%#m;%s;%T@\n' \) \
\))

echo "$tree" | awk -F\; 'NF!=4 { print $0; exit 1 }' >&2 ||
    { echo 'Invalid line found in tree' >&2; exit 1; }

tree=$(echo "$tree" | LC_ALL=C sort -t\; -k1,1)

if [ -z "$hash_func" ]; then
    echo "$tree"
    exit
fi

################################################################################

case $hash_func in
    md5|sha1|sha224|sha256|sha384|sha512|blake2b|sm3) compute_hash() {
        cksum -a"$hash_func" --untagged "$@" | cut -d' ' -f1; };;
    *) echo "Invalid hash function: $hash_func" >&2; exit 1;;
esac

tree_knowns=$(</dev/stdin)

declare -A map_knowns

if [ -n "$tree_knowns" ]; then
    echo "$tree_knowns" | awk -F\; 'NF!=5 { print $0; exit 1 }' >&2 ||
        { echo 'Invalid line found in tree_knowns' >&2; exit 1; }

    while IFS= read -r line; do
        hash=${line##*;}
        [ -n "$hash" ] || continue
        map_knowns["${line%;*}"]=$hash
    done < <(echo "$tree_knowns")
fi

echo "$tree" | while IFS= read -r line; do
    [[ "$line" != *\;DIR ]] || { echo "$line;"; continue; }

    hash=${map_knowns[$line]}
    [ -n "$hash" ] || hash=$(compute_hash "$main_dir/${line%%;*}")

    echo "$line;$hash"
done
