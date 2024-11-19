#!/bin/bash

set -e

# Usage example:
#   ./generate-badge.sh '&#x1F3E0;' 'Text here' > mybadge.svg

readonly emoji=${1:?} text=${2:?} color_fg=${3:-fff} color_bg=${4:-555}

readonly width_text=$((${#text} * 6))
readonly width_total=$((32 + width_text))

echo -n '<svg xmlns="http://www.w3.org/2000/svg" width="'"$width_total"'" height="20">'

echo -n '<rect width="'"$width_total"'" height="20" fill="#'"$color_bg"'"/>'

echo -n '<g fill="#'"$color_fg"'" font-family="Consolas,monospace" font-size="11">'
echo -n '<text x="4" y="14">'"$emoji"'</text>'
echo -n '<text x="24" y="14" textLength="'"$width_text"'">'"$text"'</text>'
echo -n '</g>'

echo -n '</svg>'
