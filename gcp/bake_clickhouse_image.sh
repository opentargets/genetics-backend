#!/usr/bin/env bash

echo create a image from machine boot disk

if [ $# -ne 2 ]; then
    echo "Usage: $0 <machine-name-source> <image-name>"
    echo "Example: $0 clickhouse-0230-dev clickhouse-0230"
    exit 1
fi

ot_project=open-targets-genetics
instance_name=$1
image_name=$2


gcloud --project=$ot_project \
    compute instances stop $instance_name

gcloud --project=$ot_project \
    compute images create "${image_name}" \
    --source-disk $instance_name \
    --family ot-ch

echo done it.
