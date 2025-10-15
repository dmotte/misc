#!/bin/bash

set -e

readonly file_in=${1:?}

code=$(awk '/^`{3}python$/{flag=1; next} /^`{3}$/{flag=0} flag' "$file_in")
echo "$code" | python3 -
