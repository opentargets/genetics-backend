# genetics-backend
QC, spin VMs, load data into DBs, create LUTs and other fun backend stuff we need to do to spin https://genetics.opentargets.io

## Dockerfile

There is a docker file to create an image with the project and required dependencies in place.

### How to run the docker container

Build image and tag it with a name for convenience of calling later:

```
    docker build --tag otg-etl .
```

### Use the Google Cloud Storage as source

Start a docker container in interactive mode.

Host names must not contain protocol (`https` is assumed) or slashes. The data loading script uses `localhost` if no hostname provided.

```
    docker run -it --rm \
    --env ES_HOST='<elasticsearch host name>' \
    --env CLICKHOUSE_HOST='<ot clickhouse db host name>' \
    --env SUMSTATS_CLICKHOUSE_HOST='<sumstats clickhouse db host name>' \
    otg-etl
```

Authenticate google cloud storage.

```
    gcloud auth application-default login
```

Load release data to `ot` database and the elasticserch.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch.sh
```

Load data to `sumstats` database.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch_summary_stats.sh
```

### Use local disk as source

Start a docker container in interactive mode.

Host names must not contain protocol (`https` is assumed) or slashes. The data loading script uses `localhost` if no hostname provided.

```
    docker run -it --rm \
    --env ES_HOST='<elasticsearch host name>' \
    --env CLICKHOUSE_HOST='<ot clickhouse db host name>' \
    --env SUMSTATS_CLICKHOUSE_HOST='<sumstats clickhouse db host name>' \
    -v <directory with data>:/data/
    otg-etl
```

Load release data to `ot` database and the elasticserch.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch.sh /data
```

Load data to `sumstats` database.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch_summary_stats.sh /data
```
