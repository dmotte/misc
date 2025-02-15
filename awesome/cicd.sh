#!/bin/bash

set -e

cd "$(dirname "$0")"

# Tested with Python 3.12.4 on Windows 10
OUTPUT_DATA=false python3 parse.py < README.md
