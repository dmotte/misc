# sftpgo

This directory contains some examples for the **SFTPGo** file server.

## example-standard

This example runs _SFTPGo_ in **standard** mode (`sftpgo serve` command, the default).

```bash
cd example-standard/

install -dv -o1000 -g1000 data home
# Initialize the SFTPGo database. This creates the sftpgo.db file
docker-compose run --rm -v "$PWD/initial-data.json:/initial-data.json:ro" sftpgo sftpgo initprovider --loaddata-from=/initial-data.json

docker-compose down && docker-compose up
```

Then you can access your **SFTPGo** instance:

- Via **web browser**: http://127.0.0.1:8080/
- Via **SFTP**: `sftp -P2022 alice@127.0.0.1`

## example-portable

This example runs _SFTPGo_ in **portable** mode (`sftpgo portable` command).

```bash
cd example-portable/

install -dv -o1000 -g1000 home serve

docker-compose down && docker-compose up
```

Then you can access your **SFTPGo** instance via **SFTP only**:

```bash
sftp -P2022 user@127.0.0.1
```

> **Note**: if you want it to be accessible only via web browser instead, you can set the `--sftpd-port=-1` and `--httpd-port=8080` flags.

## Useful info

You can find the complete list of all the _SFTPGo_ **ACL permissions** (with descriptions) in this file: https://github.com/drakkan/sftpgo/blob/fef388d8cbd50db9ab7d38f8bc02a7ebde140407/internal/dataprovider/user.go#L40-L77

## Links

- [Docker - SFTPGo documentation](https://sftpgo.github.io/2.7/docker/)
