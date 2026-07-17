# sshset

TODO this project is still work in progress!

```bash
for i in {alpine,debian}-{root,unpriv}; do
    docker build -t "img-sshset-$i" -f "test-$i.Dockerfile" .
done
```

```bash
mkdir -pv volumes/host-keys

docker run -it --rm \
    -v"$PWD/volumes/host-keys:/opt/sshset/host-keys" \
    img-sshset-debian-root
```
