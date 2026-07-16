# sshset

TODO this project is still work in progress!

```bash
docker build -t img-sshset-alpine-root -f test-alpine-root.Dockerfile .
docker build -t img-sshset-alpine-unpriv -f test-alpine-unpriv.Dockerfile .
docker build -t img-sshset-debian-root -f test-debian-root.Dockerfile .
docker build -t img-sshset-debian-unpriv -f test-debian-unpriv.Dockerfile .
```

```bash
docker run -it --rm img-sshset-alpine-root
docker run -it --rm img-sshset-alpine-unpriv
docker run -it --rm img-sshset-debian-root
docker run -it --rm img-sshset-debian-unpriv
```
