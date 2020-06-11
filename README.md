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

### Download release data from FTP to local file system

You can use wget to download the release data. Below is an example of the command for `19.05.04` release data.

```bash
    wget --mirror ftp://ftp.ebi.ac.uk/pub/databases/opentargets/genetics/190504/
```

## Clickhouse and Elastic Search

| Date | Name | Version | 
| --- | --- | --- | 
| 11/6/20 | ElasticSearch | [7.7.1](https://www.elastic.co/guide/en/elasticsearch/reference/7.7/getting-started-install.html) |
| 11/6/20 | ClickHouse | [20.1.4](https://clickhouse.tech/docs/en/) |
 


Clickhouse is currently used by the Genetics Platform and API. A number of [scripts](gcp/clickhouse) are provided to 
create and configure VM instances. 

- __bake\_clickhouse\_*.sh__: Create a GCP compute engine _image_ 
- __clickhouse\_node\_es.sh__: Initialisation script to install and configure Clickhouse and ElasticSearch  
- __clickhouse\_node\_sumstats.sh__: Initialisation script to install and configure Clickhouse  
- __create\_clickhouse\_node*.sh__: Create GCP _instance_  

### Creating the persistence layer for the Genetics API

- Create the machine with this [script](gcp/create_clickhouse_node_es.sh). It automatically calls a [startup script](gcp/clickhouse_node_es.sh) that configures the machine with Clickhouse and ElasticSearch.
- The startup script will fetch the latest version of the data from [Github](loaders/clickhouse) and call this [script](loaders/clickhouse/create_and_load_everything_from_scratch.sh) to add the data to ClickHouse and ElasticSearch.



 
