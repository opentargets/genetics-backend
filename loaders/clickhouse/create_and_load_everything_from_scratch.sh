#!/bin/bash

# CURRENTLY, IN ORDER TO BUILD SOME TABLES WE NEED A HIGHMEM MACHINE
#set -e
set -x

if [ $# -eq 0 ]; then
    echo "Loads the opentargets genetics data to clickhouse database and elasticsearch."
    echo "Usage: $0 google_storage_url_or_local_dir_location"
    echo "Example 1: $0 /home/user/open-targets-genetics-releases/19.03.03"
    echo "Example 2: $0 gs://open-targets-genetics-releases/19.03.03"
    exit 1
fi

if [[ $1 == gs:* ]]; then
   echo using Google Storage utils to read data
   cat_cmd="gsutil cat"
else
   echo using local file system to read data
   cat_cmd="cat"
fi

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_path=${1}
echo "loading files from ${base_path}"
es_host="${ES_HOST:-localhost}"
clickhouse_host="${CLICKHOUSE_HOST:-localhost}"

echo "loading data to clikhouse with host ${clickhouse_host}"
echo create genes table
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/genes.sql
"${cat_cmd}" ${base_path}/lut/genes-index/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.genes format JSONEachRow "

echo create studies tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/studies_log.sql
"${cat_cmd}" ${base_path}/lut/study-index/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.studies_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/studies.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.studies_log;"

echo create studies overlap tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/studies_overlap_log.sql
"${cat_cmd}" ${base_path}/lut/overlap-index/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.studies_overlap_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/studies_overlap.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.studies_overlap_log;"

echo create dictionaries tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/dictionaries.sql

echo create variants tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/variants_log.sql
"${cat_cmd}" ${base_path}/lut/variant-index/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.variants_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/variants.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.variants_log;"

echo create d2v2g tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/d2v2g_log.sql
"${cat_cmd}" ${base_path}/d2v2g/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.d2v2g_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/d2v2g.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.d2v2g_log;"

echo create v2d tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2d_log.sql
"${cat_cmd}" ${base_path}/v2d/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.v2d_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2d.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.v2d_log;"

echo create v2g tables
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2g_log.sql
"${cat_cmd}" ${base_path}/v2g/part-* | clickhouse-client -h "${clickhouse_host}" --query="insert into ot.v2g_log format JSONEachRow "
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2g.sql
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop table ot.v2g_log;"

echo create v2g structure
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2g_structure.sql

#echo compute v2g_scored table
#clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/v2g_scored.sql

echo compute d2v2g_scored table
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/d2v2g_scored.sql

echo compute locus 2 gene table
clickhouse-client -h "${clickhouse_host}" -m -n < ${script_dir}/d2v2g_scored_l2g.sql

# elasticsearch process
echo "loading data to elasticsearch with host ${es_host}"
echo load elasticsearch studies data
curl -XDELETE ${es_host}:9200/studies
"${cat_cmd}" ${base_path}/lut/study-index/part-* | elasticsearch_loader --es-host http://${es_host}:9200 --index-settings-file ${script_dir}/index_settings_studies.json --bulk-size 10000 --index studies --type study json --json-lines -

echo load elasticsearch genes data
curl -XDELETE ${es_host}:9200/genes
"${cat_cmd}" ${base_path}/lut/genes-index/part-* | elasticsearch_loader --es-host http://${es_host}:9200 --index-settings-file ${script_dir}/index_settings_genes.json --bulk-size 10000 --index genes --type gene json --json-lines -

echo load elasticsearch variants data
for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
	chrU=$(echo -n $chr | awk '{print toupper($0)}')
    echo "Updating index for ${chrU} chromosome."
	curl -XDELETE ${es_host}:9200/variant_$chr
	clickhouse-client -h "${clickhouse_host}" -q "select * from ot.variants prewhere chr_id = '${chrU}' format JSONEachRow" | elasticsearch_loader --es-host http://${es_host}:9200 --index-settings-file ${script_dir}/index_settings_variants.json --bulk-size 10000 --index variant_$chr --type variant json --json-lines -
done
