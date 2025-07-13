# snell-server-docker

[![Version](https://img.shields.io/docker/v/geekdada/snell-server?style=flat-square)](https://hub.docker.com/r/geekdada/snell-server/)
[![Docker Pulls](https://img.shields.io/docker/pulls/geekdada/snell-server.svg?style=flat-square)](https://hub.docker.com/r/geekdada/snell-server/)

Docker image for [snell-server](https://manual.nssurge.com/others/snell.html)

## Usage

### Available versions

> **Note**
>
> Version 4 isn't compatible with version 3 clients

All available versions are listed in [tags](https://hub.docker.com/r/geekdada/snell-server/tags/).

### Run

Environment variable `PORT` is optional, port number `9102` will be used if `PORT` is absent.

```bash
docker run -e PSK=<your_psk_here> -e PORT=9102 -p <your_host_port_here>:9102 --restart unless-stopped -d geekdada/snell-server:latest
```

If you want to use the service as a Surge Ponte relay server, exposing all ports is recommended:

```bash
docker run -e PSK=<your_psk_here> --name snell --restart unless-stopped --network host -d geekdada/snell-server:latest
```

### Run with [shadow-tls](https://github.com/ihciah/shadow-tls)

Use `docker-compose.yml` to run snell-server with shadow-tls. Please change the environment variables in `docker-compose.yml` to your own.
