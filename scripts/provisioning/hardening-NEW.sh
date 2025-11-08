#!/bin/bash

set -e

# This script contains several hardening recipes for Linux hosts

# Tested on Debian 13 (trixie)

# Usage example:
#   sudo HARDENING_RELOAD=always bash hardening.sh TODOrecipes

# Warning: this is only a partial hardening and it should only serve as
# inspiration to make your own real hardening based on your specific environment

[ "$EUID" = 0 ] || { echo 'This script must be run as root' >&2; exit 1; }

# TODO in the end: test everything thoroughly
# TODO in the end: make sure to put all the stuff from the old hardening.sh

# TODO verbose recipes
# TODO no more installed_xxx vars; be explicit about all the recipes in the args instead
# TODO force the order of recipes appropriately (and final restarts accordingly)
# TODO multiple changed_xxx vars, so you can simplify the checks in the final restarts
