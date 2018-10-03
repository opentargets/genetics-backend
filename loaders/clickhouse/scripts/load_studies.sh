#!/bin/bash

export filename="gs://genetics-portal-data/v2d/studies.json"
echo "loading file ${filename}"

gsutil cat $filename | clickhouse-client -h 127.0.0.1 --query="insert into ot.studies_log format JSONEachRow "
