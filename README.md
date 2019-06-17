# genetics-backend
QC, spin VMs, load data into DBs, create LUTs and other fun backend stuff we need to do to spin https://genetics.opentargets.io

## Dockerfile

There is a docker file to create an image with the project and required dependencies in place.

### How to run the docker container

Build image and tag it with a name for convenience of calling later:

```
    docker build --tag otg-etl .
```

Start a docker container in interactive mode.

```
    docker run -it --rm otg-etl
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
