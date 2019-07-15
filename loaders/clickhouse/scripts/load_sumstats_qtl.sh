#!/usr/bin/env bash

export SUMSTATS_CLICKHOUSE_HOST="${SUMSTATS_CLICKHOUSE_HOST:-localhost}"

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

gsutil ls -r gs://genetics-portal-sumstats/molecular_qtl/** \
    | tee qtl-inputlist.txt \
    | xargs -P 16 -I {} sh -c '
        EXPERIMENT=`echo {} | cut -d/ -f 5`
        STUDY=`echo {} | cut -d/ -f 6`
        TISSUE=`echo {} | cut -d/ -f 7`
        BIOMARK=`echo {} | cut -d/ -f 8`
        gsutil cat {} \
            | zcat \
            | sed 1d \
            | sed -e "s/^/$EXPERIMENT\t$STUDY\t$TISSUE\t$BIOMARK\t/" \
            | clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="insert into sumstats.molecular_qtl_log format TabSeparated"

        echo {} | tee -a qtl-done.log'
