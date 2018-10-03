#!/bin/bash

export filename="gs://genetics-portal-output/v2d/part-*"
echo "loading file ${filename}"

gsutil cat $filename | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2d_log format JSONEachRow "
