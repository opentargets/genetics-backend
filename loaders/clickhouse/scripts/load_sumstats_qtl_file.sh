#!/usr/bin/env bash

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -ne 1 ]; then
    echo "Loads single qtl compressed file data accompanied with experiment, study, tissue and biomarker information that are parsed from the path to the database."
    echo "Example: $0 gs://genetics-portal-sumstats/molecular_qtl/experiment/study/tissue/biomarker/data.tsv.gz"
    exit 1
fi

IFS='/' read -r -a path <<< "$1"
PARTS=${#path[@]}
EXPERIMENT=${path[$PARTS-5]}
STUDY=${path[$PARTS-4]}
TISSUE=${path[$PARTS-3]}
BIOMARK=${path[$PARTS-2]}
"${SCRIPT_DIR}/../run.sh" cat "$1" \
    | zcat \
    | sed 1d \
    | sed -e "s/^/$EXPERIMENT\t$STUDY\t$TISSUE\t$BIOMARK\t/" \
    | clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="insert into sumstats.molecular_qtl_log format TabSeparated"

