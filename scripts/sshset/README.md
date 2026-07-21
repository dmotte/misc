# sshset

TODO this project is still work in progress!

```bash
for i in {alpine,debian}-{root,unpriv}; do
    docker build -t "img-sshset-$i" -f "test-$i.Dockerfile" .
done
```

```bash
mkdir -pv volumes/{sshd-config,host-keys}

docker run -it --rm \
    -v"$PWD/volumes/sshd-config:/opt/sshset/sshd-config" \
    -v"$PWD/volumes/host-keys:/opt/sshset/host-keys" \
    -v"$PWD/volumes/rc:/opt/sshset/rc" \
    img-sshset-debian-root
```
