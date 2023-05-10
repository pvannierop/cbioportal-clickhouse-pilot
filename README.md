# Using Clickhouse OLAP to support Study View cohort queries (pilot)

## Description

This repo will provision and run a Clickhouse instance with data from _msk_met_2012_,
_msk_ch_2020_ and _msk_imapct_2017_ datahub studies. This Clickhouse instance can be
used by a modified cBioPortal backend to run cohort/filter queries in Study View.

## Connection with cBioPortal MySQL database

Clickhouse performs well for analytical queries (search on column values) but is less suitable to retrieve all column
values on an entity (typically _SELECT * FROM ..._). In the current implementation the _samples_ table contains a column
with internal sample identifiers used in the cBioPortal MySQL database. This allows for efficient retrieval of sample
objects (created with _SELECT * FROM sample ..._ in the MySQL database) once Clickhouse has determined the correct
sample identifiers in the cohort.

The clickhouse schema is defined in `clickhouse_provisioning/` directory

## Installation

1. Edit the `study_configs` section in _create_clickhouse_db_table_files.py_ file to reflect paths to _msk_met_2012_,
   _msk_ch_2020_ and _msk_imapct_2017_ datahub studies

```python
study_configs = [
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_met_2021",
        "name": "msk_met_2021"
    },
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_ch_2020",
        "name": "msk_ch_2020"
    },
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_impact_2017",
        "name": "msk_impact_2017"
    }
]
```

2. Create Clickhouse staging files in the _clickhouse_provisioning_ directory (in this repo) by running the
   _create_clickhouse_db_table_files.py_ script:

```shell
python3 create_clickhouse_db_table_files.py
```

3. Provision and run Clickhouse by running the _docker-compose.yml_ file:

```shell
docker-compose up
``` 

or for detached mode:

```shell
docker-compose up -d
```

This will start a Clickhouse instance with port `8123` exposed on the host system.