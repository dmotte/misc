#!/bin/bash

set -e

# This script should be run automatically by the CI/CD

cd "$(dirname "$0")"

# Tested with Python 3.12.4 on Windows 10
OUTPUT_DATA=false exec python3 parse.py < README.md
