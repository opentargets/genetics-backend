# genetics-backend
QC, spin VMs, load data into DBs, create LUTs and other fun backend stuff we need to do to spin https://genetics.opentargets.io

## Dockerfile

There is a docker file to create an image with the project and required dependencies in place.

### How to run the docker container

Build image and tag it with a name for convenience of calling later:

```
    docker build --tag otg-etl .
```

### Use the Google Cloud Storage as source to load release data

Start a docker container in interactive mode.

Host names must not contain protocol (`https` is assumed) or slashes. The data loading script uses `localhost` if no host name provided.

```
    docker run -it --rm \
    --env ES_HOST='<elasticsearch host name>' \
    --env CLICKHOUSE_HOST='<ot clickhouse db host name>' \
    otg-etl
```

Authenticate google cloud storage.

```
    gcloud auth application-default login
```

Load release data to `ot` database and the Elasticserch.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch.sh gs://genetics-portal-output/190504
```

### Use local disk as source to load release data

Start a docker container in interactive mode.

Host names must not contain protocol (`https` is assumed) or slashes. The data loading script uses `localhost` if no host name provided.

```
    docker run -it --rm \
    --env ES_HOST='<elasticsearch host name>' \
    --env CLICKHOUSE_HOST='<ot clickhouse db host name>' \
    -v <directory with data>:/data/
    otg-etl
```

Load release data to `ot` database and the Elasticserch.

```
    bash genetics-backend/loaders/clickhouse/create_and_load_everything_from_scratch.sh /data
```
