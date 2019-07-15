#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Loads single gwas compressed file data accompanied with chip, study and trait information that are parsed from the path to the database."
    echo "Example: $0 gs://genetics-portal-sumstats/gwas/chip/study/trait/data.tsv.gz"
    exit 1
fi

CHIP=`echo $1 | cut -d/ -f 5`
STUDY=`echo $1 | cut -d/ -f 6`
TRAIT=`echo $1 | cut -d/ -f 7`
gsutil cat $1 \
    | zcat \
    | sed 1d \
    | sed -e "s/^/$CHIP\t$STUDY\t$TRAIT\t/" \
    | clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="insert into sumstats.gwas_log format TabSeparated"
