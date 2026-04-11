# html-dir-index

**HTML**-based **dir**ectory **index**.

The [`generate.sh`](generate.sh) script can be used like this:

```bash
find test -type d -exec bash -ec 'bash '"$PWD"'/generate.sh '"$PWD"'/template.html "$1" "/$1" > "$1/index.html"' _ {} \;
```
