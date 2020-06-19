#!/usr/bin/env bash

ot_project=open-targets-genetics

if [ $# -ne 1 ]; then
    echo "Usage: $0 <tag-name>"
    exit 1
fi

gcloud compute instances create clickhouse-$1  \
       --image-project debian-cloud \
       --image-family debian-10 \
       --machine-type n1-highmem-16 \
       --zone europe-west1-d \
       --metadata-from-file startup-script=clickhouse_node_es.sh \
       --boot-disk-size "500" \
       --boot-disk-type "pd-ssd" --boot-disk-device-name "clickhouse-ssd-$1" \
       --project $ot_project \
       --scopes default,storage-rw

