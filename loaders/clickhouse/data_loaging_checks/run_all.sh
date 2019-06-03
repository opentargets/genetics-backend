#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Run all stat. scripts on input and output data"
    echo "Usage: $0 google_storage_url_or_local_dir_location"
    echo "Example 1: $0 /home/user/open-targets-genetics-releases/19.03.03"
    echo "Example 2: $0 gs://open-targets-genetics-releases/19.03.03"
    exit 1
fi

echo ot input files:
./ot_json_files_lines.sh $1
echo sumstats input files:
./sumstats_gwas_files_lines.sh $1

echo ot load tables:
./ot_load_tables_rows.sh
echo ot calc tables:
./ot_calc_tables_rows.sh
echo ot elasticsearch:
./ot_es_docs.sh
echo gwas tables:
./sumstats_gwas_tables_rows.sh
