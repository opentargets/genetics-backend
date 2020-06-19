#!/usr/bin/env bash

ot_project=open-targets-genetics

if [ $# -ne 1 ]; then
    echo "Usage: $0 <tag-name>"
    exit 1
fi

gcloud compute instances create clickhouse-sumstats-$1  \
       --image-project debian-cloud \
       --image-family debian-9 \
       --machine-type n1-highmem-8 \
       --zone europe-west1-d \
       --metadata-from-file startup-script=clickhouse_node_sumstats.sh \
       --boot-disk-size "500" \
       --boot-disk-type "pd-ssd" --boot-disk-device-name "clickhouse-sumstats-ssd-$1" \
       --project $ot_project \
       --scopes default,storage-rw

