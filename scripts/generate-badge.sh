#!/bin/bash

set -e

# Usage example:
#   ./generate-badge.sh '&#x1F3E0;' 'Text here' > mybadge.svg

readonly emoji=${1:?} text=${2:?} color_fg=${3:-fff} color_bg=${4:-555}

readonly width=$((32 + ${#text} * 6))

cat << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="20">
    <rect width="$width" height="20" fill="#$color_bg"/>
    <text x="4" y="14" fill="#$color_fg" font-family="Consolas,monospace" font-size="11">$emoji $text</text>
</svg>
EOF
