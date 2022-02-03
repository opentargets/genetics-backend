#!/usr/bin/env bash

echo create a image from machine boot disk

if [ $# -ne 1 ]; then
    echo "Usage: $0 <machine-name-source>"
    echo "Example: $0 ch-1710011203"
    exit 1
fi

ot_project=open-targets-genetics-dev
instance_name=$1


gcloud --project=$ot_project \
    compute instances stop $instance_name

gcloud --project=$ot_project \
    compute images create "${instance_name/node/image}" \
    --source-disk $instance_name \
    --family ot-genetics-ch

echo Image created for $instance_name.