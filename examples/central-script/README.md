# central-script

Sometimes people use a `Makefile` ([Make](https://www.gnu.org/software/make/)) just to have a list of shortcuts for frequently used commands. For example:

```make
.PHONY: prepare lint build-docker

prepare:
    sudo apt-get update
    sudo apt-get install -y docker.io

lint:
    npx prettier -c .

build-docker: lint
    docker build -t $(imgname) .
```

I know that _Make_ can do a lot more than that, but sometimes, for simple scenarios, this is enough. If this is the case, in my opinion there's no reason to use _Make_ at all: we can do pretty much the same with a simple Bash script like the following:

```bash
#!/bin/bash

set -e

cd "$(dirname "$0")"

target_prepare() { sudo apt-get update; sudo apt-get install -y docker.io; }
target_lint() { npx prettier -c .; }
target_build_docker() { target_lint; docker build -t "$1" .; }

echo "$1" | tr , '\n' | while read -r i; do "target_$i" "${@:2}"; done
```

Then we can save it in the root of our project and invoke it like this:

```bash
./central.sh prepare,build-docker myimage
```
