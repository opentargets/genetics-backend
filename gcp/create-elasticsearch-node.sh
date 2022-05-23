#!/usr/bin/env bash

ot_project=open-targets-genetics-dev
node_name=$(date +"%y%m%d%H")

#if [ $# -ne 1 ]; then
#    echo "Usage: $0 <tag-name>"
#    exit 1
#fi

echo creating node elasticsearch-genetics-node-$node_name

gcloud compute instances create elasticsearch-genetics-node-$node_name  \
       --image-project debian-cloud \
       --image-family debian-10 \
       --machine-type n1-highmem-4 \
       --zone europe-west1-d \
       --metadata-from-file startup-script=elasticsearch-node.sh \
       --boot-disk-size "250" \
       --boot-disk-type "pd-ssd" --boot-disk-device-name "elasticsearch-genetics-disk-${node_name}" \
       --project $ot_project \
       --scopes default,storage-rw

