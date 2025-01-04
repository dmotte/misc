#!/bin/bash

set -e

readonly vagrant_pwd=/home/vagrant/${PWD#"$HOME/"}

cd "$(dirname "$0")"

vagrant ssh -c "cd $vagrant_pwd && ${*:-/bin/bash}"
