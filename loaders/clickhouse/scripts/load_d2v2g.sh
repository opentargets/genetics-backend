#!/bin/bash

export filename="gs://genetics-portal-output/d2v2g/part-*"
echo "loading file ${filename}"

gsutil cat $filename | clickhouse-client -h 127.0.0.1 --query="insert into ot.d2v2g_log format JSONEachRow "
