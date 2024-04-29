#!/bin/bash

set -e

vagrant_pwd=/home/vagrant/${PWD#"$HOME/"}

cd "$(dirname "$0")"

vagrant ssh -c "cd $vagrant_pwd && ${*:-/bin/bash}"
