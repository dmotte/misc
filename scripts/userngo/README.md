# userngo

This is a simple Bash script [`userngo.sh`](userngo.sh) that can be used to **create a user "on the go"** at startup in a Docker container, based on some environment variables, and use it to run the actual containerized application.

TODO this is still work in progress!

TODO add commented `ADD` directives to Dockerfiles

## Usage

This is meant to be used in a `Dockerfile`. See [`alpine.Dockerfile`](alpine.Dockerfile) and [`debian.Dockerfile`](debian.Dockerfile) for usage examples.

## Development

You can use the following commands to build and run the examples:

```bash
docker build -t img-userngo-alpine -f alpine.Dockerfile .
docker run -it --rm img-userngo-alpine

docker build -t img-userngo-debian -f debian.Dockerfile .
docker run -it --rm img-userngo-debian
```

TODO add some env vars to the examples here
