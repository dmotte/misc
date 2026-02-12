# ustreamer

```bash
docker-compose up -d
```

Then you can access your **MJPEG video stream** at http://localhost:8080/stream

> **Note**: in case you are using **rootless Podman**, the host user must be in the `video` group in order to be able to access the `/dev/video*` devices, and you need to pass the `--group-add=keep-groups` option to the `podman run` command. See https://www.redhat.com/sysadmin/files-devices-podman for more information.

## Links

- [pikvm/ustreamer: uStreamer - Lightweight and fast MJPEG-HTTP streamer](https://github.com/pikvm/ustreamer)
- [Debian -- Details of package ustreamer in trixie](https://packages.debian.org/trixie/ustreamer)
- [pikvm/ustreamer - Docker Image](https://hub.docker.com/r/pikvm/ustreamer)
