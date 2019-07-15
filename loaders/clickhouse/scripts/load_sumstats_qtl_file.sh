#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Loads single qtl compressed file data accompanied with experiment, study, tissue and biomarker information that are parsed from the path to the database."
    echo "Example: $0 gs://genetics-portal-sumstats/molecular_qtl/experiment/study/tissue/biomarker/data.tsv.gz"
    exit 1
fi

EXPERIMENT=`echo $1 | cut -d/ -f 5`
STUDY=`echo $1 | cut -d/ -f 6`
TISSUE=`echo $1 | cut -d/ -f 7`
BIOMARK=`echo $1 | cut -d/ -f 8`
gsutil cat $1 \
    | zcat \
    | sed 1d \
    | sed -e "s/^/$EXPERIMENT\t$STUDY\t$TISSUE\t$BIOMARK\t/" \
    | clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="insert into sumstats.molecular_qtl_log format TabSeparated"

