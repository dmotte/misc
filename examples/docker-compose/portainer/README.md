# portainer

```bash
docker-compose up -d
```

Then you can visit the _Portainer_ **Web UI** at https://localhost:9443/. Login with username `admin` and password `changeme`.

To generate the hash value for the `--admin-password` CLI argument I used the following command:

```bash
docker run --rm httpd:2.4-alpine htpasswd -nbB admin changeme
```

The `debian01` container is just a sample _Debian_ container.

## Podman

To make this work with _Podman_ you'll need to:

- Enable and start the **Podman socket** with `systemctl enable --now podman.socket`
- In the [`docker-compose.yml`](docker-compose.yml) file, prepend `docker.io/` to the image names (e.g. `docker.io/portainer/portainer-ce`)
- In the [`docker-compose.yml`](docker-compose.yml) file, change the `docker.sock` volume mount line to point to the _Podman_ socket on the host. You can use the `systemctl status podman.socket | grep 'Listen:'` command to get the right socket path

If you want to run the _Podman_ socket as **non-root** user, add the `--user` switch to the `systemctl` commands above.

Then:

```bash
podman-compose up -d
```

## Links

- [Install Portainer with Docker on Linux](https://docs.portainer.io/start/install/server/docker/linux)
- [Portainer admin password in a docker-compose environment](https://gist.github.com/deviantony/62c009b41bde5e078b1a7de9f11f5e55)
- [Podman socket activation](https://github.com/containers/podman/blob/main/docs/tutorials/socket_activation.md)
