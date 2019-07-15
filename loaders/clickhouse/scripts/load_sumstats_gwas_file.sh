#!/usr/bin/env bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -ne 1 ]; then
    echo "Loads single gwas compressed file data accompanied with chip, study and trait information that are parsed from the path to the database."
    echo "Example: $0 gs://genetics-portal-sumstats/gwas/chip/study/trait/data.tsv.gz"
    exit 1
fi

IFS='/' read -r -a path <<< "$1"
PARTS=${#path[@]}
CHIP=${path[$PARTS-4]}
STUDY=${path[$PARTS-3]}
TRAIT=${path[$PARTS-2]}
"${SCRIPT_DIR}/../run.sh" cat "$1" \
    | zcat \
    | sed 1d \
    | sed -e "s/^/$CHIP\t$STUDY\t$TRAIT\t/" \
    | clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="insert into sumstats.gwas_log format TabSeparated"
