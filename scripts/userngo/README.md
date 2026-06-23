# userngo

These are simple Bash scripts [`userngo-alpine.sh`](userngo-alpine.sh) and [`userngo-debian.sh`](userngo-debian.sh) that can be used to **create a user "on the go"** at startup in a Docker container, based on some environment variables, and use it to run the actual containerized application.

## Examples

These scripts are meant to be used in a `Dockerfile`. See [`test-alpine.Dockerfile`](test-alpine.Dockerfile) and [`test-debian.Dockerfile`](test-debian.Dockerfile) for **usage examples**. They are also useful for **development**.

To **build** the example images:

```bash
docker build -t img-userngo-alpine -f test-alpine.Dockerfile .
docker build -t img-userngo-debian -f test-debian.Dockerfile .
```

To run as **`root` user**:

```bash
docker run -it --rm img-userngo-alpine
docker run -it --rm img-userngo-debian
```

To run as **custom user** created "on the go":

```bash
docker run -it --rm -eUSERNGO_{NAME=myuser,PSW=mypassword,{WHEEL,NOPASS}=true} img-userngo-alpine
docker run -it --rm -eUSERNGO_{NAME=myuser,PSW=mypassword,{SUDOER,NOPASSWD}=true} img-userngo-debian
```

To **extend the images** and run as **unprivileged user**:

```bash
docker build -t img-userngo-alpine-unpriv:latest - << 'EOF'
FROM img-userngo-alpine
RUN adduser -Ds/bin/bash user
USER user
ENV USER=user HOME=/home/user
WORKDIR /home/user
EOF
docker run -it --rm img-userngo-alpine-unpriv

docker build -t img-userngo-debian-unpriv:latest - << 'EOF'
FROM img-userngo-debian
RUN useradd -Ums/bin/bash user
USER user
ENV USER=user HOME=/home/user
WORKDIR /home/user
EOF
docker run -it --rm img-userngo-debian-unpriv
```
