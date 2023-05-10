# Express installation for cBioPortal Hackathon

## Installation

1. Download [this archive](https://drive.google.com/file/d/1hENRwKRdJ4APUwlA81SfDy29q5DZRAOY/view?usp=sharing) and
   decompress in _clickhouse_provisioning_ directory.

3. Provision and run Clickhouse by running the _docker-compose.yml_ file:

```shell
docker-compose up -d
```

This will start a Clickhouse instance with port `8123` exposed on the host system and added to the _cbio-net_ docker
network.