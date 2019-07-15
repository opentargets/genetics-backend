#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Loads sumstats data"
    echo "Example: $0 gs://genetics-portal-sumstats-b38/filtered/pvalue_0.05"
    exit 1
fi

base_path="${1}"

export CLICKHOUSE_HOST="${CLICKHOUSE_HOST:-localhost}"
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo generate gwas log and mergetree tables

gwas_files=$("${SCRIPT_DIR}/run.sh" ls "${base_path}/gwas/part-*")
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < v2d_sa_gwas_log.sql
for file in $gwas_files; do
        echo $file
        "${SCRIPT_DIR}/run.sh" cat "${file}" | \
         clickhouse-client -h "${CLICKHOUSE_HOST}" \
             --query="insert into ot.v2d_sa_gwas_log format JSONEachRow "
done
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < v2d_sa_gwas.sql

echo create genes table

moltraits_files=$("${SCRIPT_DIR}/run.sh" ls "${base_path}/molecular_trait/part-*")
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < v2d_sa_molecular_traits_log.sql
for file in $moltraits_files; do
        echo $file
        "${SCRIPT_DIR}/run.sh" cat "${file}" | \
         clickhouse-client -h "${CLICKHOUSE_HOST}" \
             --query="insert into ot.v2d_sa_molecular_trait_log format JSONEachRow "
done
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < v2d_sa_molecular_traits.sql
