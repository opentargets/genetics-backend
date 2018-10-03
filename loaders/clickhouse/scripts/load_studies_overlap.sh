#!/bin/bash

export filename="gs://genetics-portal-data/v2d/locus_overlap.json.gz"
echo "loading file ${filename}"

gsutil cat $filename | gunzip | clickhouse-client -h 127.0.0.1 --query="insert into ot.studies_overlap_log format JSONEachRow "
