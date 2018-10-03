#!/bin/bash

export filename="gs://genetics-portal-output/variant-index-lut/part-*"
echo "loading file ${filename}"

gsutil cat $filename | clickhouse-client -h 127.0.0.1 --query="insert into ot.variants_log format JSONEachRow "
