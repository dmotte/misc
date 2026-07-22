# sshset

TODO this project is still work in progress!

```bash
for i in {alpine,debian}-{root,unpriv}; do
    docker build -t "img-sshset-$i" -f "test-$i.Dockerfile" .
done
```

```bash
mkdir -pv data

docker run -it --rm -v"$PWD/data:/opt/sshset/data" img-sshset-debian-root
```
