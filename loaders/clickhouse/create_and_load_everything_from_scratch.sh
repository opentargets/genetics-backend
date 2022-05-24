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

## Database setup
# drop all dbs
echo "Initialising database..."
clickhouse-client -h "${CLICKHOUSE_HOST}" --query="drop database if exists ot;"

intermediateTables=(
  studies
  studies_overlap
  variants
  v2d
  v2g_scored
  d2v2g_scored
  v2d_coloc
  v2d_credibleset
  v2d_sa_gwas
  v2d_sa_molecular_traits
  l2g
  manhattan
)
## Create intermediary tables
for t in "${intermediateTables[@]}"; do 
  echo "Creating intermediary table: ${t}";
  clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/${t}_log.sql";
done

## Load data
load_foreach_parquet "${base_path}/lut/study-index" "ot.studies_log" &
load_foreach_parquet "${base_path}/lut/overlap-index" "ot.studies_overlap_log" &
load_foreach_parquet "${base_path}/lut/variant-index" "ot.variants_log" &
load_foreach_parquet "${base_path}/d2v2g_scored" "ot.d2v2g_scored_log" &
load_foreach_parquet "${base_path}/v2d" "ot.v2d_log" &
load_foreach_parquet "${base_path}/v2g_scored" "ot.v2g_scored_log" &
load_foreach_parquet "${base_path}/v2d_coloc" "ot.v2d_coloc_log" &
load_foreach_parquet "${base_path}/v2d_credset" "ot.v2d_credset_log" &
load_foreach_parquet "${base_path}/sa/gwas" "ot.v2d_sa_gwas_log" &
load_foreach_parquet "${base_path}/sa/molecular_trait" "ot.v2d_sa_molecular_trait_log" &
load_foreach_parquet "${base_path}/l2g" "ot.l2g_log" &
load_foreach_parquet "${base_path}/manhattan" "ot.manhattan_log" &
wait

## Create final tables
finalTables=(
  genes
  studies
  studies_overlap
  variants
  v2d
  v2g_scored
  v2g_structure
  d2v2g_scored
  v2d_coloc
  v2d_credibleset
  v2d_sa_gwas
  v2d_sa_molecular_traits
  l2g
  manhattan
)

## Create final tables
for t in "${finalTables[@]}"; do 
  echo "Creating table: ${t}";
  clickhouse-client -m -n < "${SCRIPT_DIR}/${t}.sql" &;
done

echo "Load gene index"
load_foreach_parquet "${base_path}/lut/genes-index" "ot.genes" &

wait 

echo create v2g structure
clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n < "${SCRIPT_DIR}/v2g_structure.sql"

## Drop intermediate tables
for t in "${intermediateTables[@]}"; do 
  echo "Deleting intermediate table: ${t}";
  clickhouse-client -h "${CLICKHOUSE_HOST}" -m -n -q " drop table ot.${t}_log";
done

# # elasticsearch process
# # elasticsearch mapping index for studies uses a weird custom date format parsing configration
# # that it is worth to correct at ETL pipeline
# echo load elasticsearch studies data
# curl -XDELETE "${ES_HOST}:9200/studies"
# "${SCRIPT_DIR}/run.sh" cat "${base_path}"/lut/study-index/part-* | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_studies.json" --bulk-size 10000 --index studies json --json-lines -

# echo load elasticsearch genes data
# curl -XDELETE "${ES_HOST}:9200/genes"
# "${SCRIPT_DIR}/run.sh" cat "${base_path}"/lut/genes-index/part-* | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_genes.json" --bulk-size 10000 --with-retry --timeout 300 --index genes json --json-lines -

# # it needs to load after clickhouse variant index loaded
# echo load elasticsearch variants data
# for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
# 	chrU=$(echo -n $chr | awk '{print toupper($0)}')
# 	curl -XDELETE "${ES_HOST}:9200/variant_${chr}"
# 	clickhouse-client -h "${CLICKHOUSE_HOST}" -q "select * from ot.variants prewhere chr_id = '${chrU}' format JSONEachRow" | elasticsearch_loader --es-host "http://${ES_HOST}:9200" --index-settings-file "${SCRIPT_DIR}/index_settings_variants.json" --bulk-size 10000 --with-retry --timeout 300 --index variant_$chr json --json-lines -
# done



