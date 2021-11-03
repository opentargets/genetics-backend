#!/bin/bash

# CURRENTLY, IN ORDER TO BUILD SOME TABLES WE NEED A HIGHMEM MACHINE

export ES_HOST="${ES_HOST:-localhost}"
export CLICKHOUSE_HOST="${CLICKHOUSE_HOST:-localhost}"
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ $# -ne 1 ]; then
    echo "Recreates ot database and loads data."
    echo "Example: $0 gs://genetics-portal-output/190504"
    exit 1
fi
base_path="${1}"

load_foreach_json(){
    # you need two parameters, the path_prefix to make the wildcard and
    # the table_name name to load into
    local path_prefix=$1
    local table_name=$2
    echo loading $path_prefix glob files into this table $table_name
    gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/part-*)
    for file in $gs_files; do
            echo $file
            "${SCRIPT_DIR}/run.sh" cat "${file}" | \
             clickhouse-client -h "${CLICKHOUSE_HOST}" \
                 --query="insert into ${table_name} format JSONEachRow "
    done
    echo "done loading $path_prefix glob files into this table $table_name"
}

load_foreach_json_gz(){
    # you need two parameters, the path_prefix to make the wildcard and
    # the table_name name to load into
    # this function is a temporal fix for a jsonlines dataset where files
    # come compressed
    local path_prefix=$1
    local table_name=$2
    echo loading $path_prefix glob files into this table $table_name
    gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/part-*)
    for file in $gs_files; do
            echo $file
            "${SCRIPT_DIR}/run.sh" cat "${file}" | gunzip | \
             clickhouse-client -h "${CLICKHOUSE_HOST}" \
                 --query="insert into ${table_name} format JSONEachRow "
    done
    echo "done loading $path_prefix glob files into this table $table_name"
}

load_foreach_parquet(){
    # you need two parameters, the path_prefix to make the wildcard and
    # the table_name name to load into
    local path_prefix=$1
    local table_name=$2
    echo loading $path_prefix glob files into this table $table_name
    gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/*.parquet)
    for file in $gs_files; do
            echo $file
            "${SCRIPT_DIR}/run.sh" cat "${file}" | \
             clickhouse-client -h "${CLICKHOUSE_HOST}" \
                 --query="insert into ${table_name} format Parquet "
    done
    echo "done loading $path_prefix glob files into this table $table_name"
}

# drop all dbs
clickhouse-client -h "${CLICKHOUSE_HOST}" --query="drop database if exists ot;"

echo create genes table
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/genes.sql"
load_foreach_json "${base_path}/lut/genes-index" "ot.genes"

echo create studies tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/studies_log.sql"
load_foreach_json "${base_path}/lut/study-index" "ot.studies_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/studies.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.studies_log;"

echo create studies overlap tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/studies_overlap_log.sql"
load_foreach_json "${base_path}/lut/overlap-index" "ot.studies_overlap_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/studies_overlap.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.studies_overlap_log;"

echo create variants tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/variants_log.sql"
load_foreach_json "${base_path}/lut/variant-index" "ot.variants_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/variants.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.variants_log;"

echo create v2d tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_log.sql"
load_foreach_json "${base_path}/v2d" "ot.v2d_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.v2d_log;"

echo create v2g tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2g_scored_log.sql"
load_foreach_json "${base_path}/v2g_scored" "ot.v2g_scored_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2g_scored.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.v2g_scored_log;"

echo create v2g structure
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2g_structure.sql"

echo create d2v2g_scored tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/d2v2g_scored_log.sql"
load_foreach_json "${base_path}/d2v2g_scored" "ot.d2v2g_scored_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/d2v2g_scored.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.d2v2g_scored_log;"

echo load coloc data
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_coloc_log.sql"
load_foreach_json "${base_path}/v2d_coloc" "ot.v2d_coloc_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_coloc.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.v2d_coloc_log;"

echo load credible set
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_credibleset_log.sql"
load_foreach_json_gz "${base_path}/v2d_credset" "ot.v2d_credset_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_credibleset.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.v2d_credset_log;"

echo generate sumstats gwas tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_sa_gwas_log.sql"
load_foreach_parquet "${base_path}/sa/gwas" "ot.v2d_sa_gwas_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_sa_gwas.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table if exists ot.v2d_sa_gwas_log;"

echo generate sumstats molecular trait tables
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_sa_molecular_traits_log.sql"
load_foreach_parquet "${base_path}/sa/molecular_trait" "ot.v2d_sa_molecular_trait_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2d_sa_molecular_traits.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table if exists ot.v2d_sa_molecular_trait_log;"

echo load locus 2 gene
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/l2g_log.sql"
load_foreach_parquet "${base_path}/l2g" "ot.l2g_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/l2g.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.l2g_log;"

echo create manhattan table
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/manhattan_log.sql"
load_foreach_json "${base_path}/manhattan" "ot.manhattan_log"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/manhattan.sql"
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q "drop table ot.manhattan_log;"

# elasticsearch process
# elasticsearch mapping index for studies uses a weird custom date format parsing configration
# that it is worth to correct at ETL pipeline
echo load elasticsearch studies data
curl -XDELETE "${ES_HOST}:9200/studies"
"${SCRIPT_DIR}/run.sh" cat "${base_path}"/lut/study-index/part-* | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_studies.json" --bulk-size 10000 --index studies json --json-lines -

echo load elasticsearch genes data
curl -XDELETE "${ES_HOST}:9200/genes"
"${SCRIPT_DIR}/run.sh" cat "${base_path}"/lut/genes-index/part-* | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_genes.json" --bulk-size 10000 --with-retry --timeout 300 --index genes json --json-lines -

# it needs to load after clickhouse variant index loaded
echo load elasticsearch variants data
for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
	chrU=$(echo -n $chr | awk '{print toupper($0)}')
	curl -XDELETE "${ES_HOST}:9200/variant_${chr}"
	clickhouse-client -h "${CLICKHOUSE_HOST}" -q "select * from ot.variants prewhere chr_id = '${chrU}' format JSONEachRow" | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_variants.json" --bulk-size 10000 --with-retry --timeout 300 --index variant_$chr json --json-lines -
done



