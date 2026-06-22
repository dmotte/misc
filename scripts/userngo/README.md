# userngo

These are simple Bash scripts [`userngo-alpine.sh`](userngo-alpine.sh) and [`userngo-debian.sh`](userngo-debian.sh) that can be used to **create a user "on the go"** at startup in a Docker container, based on some environment variables, and use it to run the actual containerized application.

TODO this is still work in progress!

## Usage

These scripts are meant to be used in a `Dockerfile`. See [`test-alpine.Dockerfile`](test-alpine.Dockerfile) and [`test-debian.Dockerfile`](test-debian.Dockerfile) for usage examples.

## Development

You can use the following commands to build and run the examples:

```bash
docker build -t img-userngo-alpine -f test-alpine.Dockerfile .
docker build -t img-userngo-debian -f test-debian.Dockerfile .

docker run -it --rm img-userngo-alpine
docker run -it --rm img-userngo-debian

docker run -it --rm -eUSERNGO_{NAME=myuser,PSW=mypassword,WHEEL=true} img-userngo-alpine
docker run -it --rm -v"$PWD/app.sh:/opt/app.sh:ro" img-userngo-alpine
```
