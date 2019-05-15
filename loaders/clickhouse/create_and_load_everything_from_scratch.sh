#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Recreates databases and loads data"
    echo "Usage: $0 google_storage_url_or_local_dir_location"
    echo "Example 1: $0 /home/user/open-targets-genetics-releases/19.03.03"
    echo "Example 2: $0 gs://open-targets-genetics-releases/19.03.03"
    exit 1
fi

echo "$(date) Starting (re)loading data."
./create_and_load_ot_from_scratch.sh "$@"
./scripts/drop_sumstats.sh
# Assuming that gwas data located at the same location with the 
./scripts/load_sumstats_gwas.sh "$@"
./scripts/sumstats_gwas_makechrtables.sh
echo "$(date) (Re)loading data has finished."
