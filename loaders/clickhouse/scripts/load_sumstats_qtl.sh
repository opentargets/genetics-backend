#!/usr/bin/env bash

export SUMSTATS_CLICKHOUSE_HOST="${SUMSTATS_CLICKHOUSE_HOST:-localhost}"
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -ne 1 ]; then
    echo "Loads qtl sumstats data"
    echo "Example: $0 gs://genetics-portal-sumstats"
    exit 1
fi

base_path=$1
# clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="create database if not exists sumstats"

clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="
create table if not exists sumstats.molecular_qtl_log(
    experiment String,
    study_id String,
    tissue String,
    biomarker String,
    variant_id_b37 String,
    chrom String,
    pos_b37 UInt32,
    ref_al String,
    alt_al String,
    beta Float64,
    se Float64,
    pval Float64,
    n_samples_variant_level Nullable(UInt32),
    n_samples_study_level Nullable(UInt32),
    n_cases_variant_level Nullable(UInt32),
    n_cases_study_level Nullable(UInt32),
    eaf Nullable(Float64),
    maf Nullable(Float64),
    info Nullable(Float64),
    is_cc String)
engine=Log;
"

"${SCRIPT_DIR}/../run.sh" ls -r "${base_path}/molecular_qtl/**" \
    | tee qtl-inputlist.txt \
    | xargs -P 16 -I {} sh -c '
        "${SCRIPT_DIR}/load_sumstats_qtl_file.sh" {}
        echo {} | tee -a qtl-done.log'
