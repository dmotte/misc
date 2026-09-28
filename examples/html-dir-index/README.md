# html-dir-index

**HTML**-based **dir**ectory **index**.

The [`generate.sh`](generate.sh) script can be used like this:

```bash
find test -type d -print -exec bash -ec 'bash '"${PWD@Q}"'/generate.sh '"${PWD@Q}"'/template.html "$1" "/$1" > "$1/index.html"' _ {} \;
```
