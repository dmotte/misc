# getopt

Example of how to use `getopt` in Bash (which, mind you, is not the `getopts` builtin).

Inspired by https://gist.github.com/drmalex07/6bcd65a0861f58b646a0.

```bash
#!/bin/bash

set -e

options=$(getopt -o abc: -l along,blong,clong: -- "$@")
eval set -- "$options"

flag_a=n
flag_b=n
arg_c=

while :; do
    case "$1" in
        -a|--along) flag_a=y;;
        -b|--blong) flag_b=y;;
        -c|--clong) shift; arg_c="$1";;
        --) shift; break;;
    esac
    shift
done

echo "$flag_a-$flag_b-$arg_c"
echo "$@"
```

> **Note**: instead of `-l along,blong,clong:` it's also possible to write `-l along -l blong -l clong:`
