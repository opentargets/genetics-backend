#!/bin/bash

root_path=$(pwd)

echo create studies tables
clickhouse-client -m -n < studies_log.sql
bash "${root_path}/scripts/load_studies.sh"
clickhouse-client -m -n < studies.sql
# clickhouse-client -m -n -q "drop table ot.studies_log;"

echo create studies overlap tables
clickhouse-client -m -n < studies_overlap_log.sql
bash "${root_path}/scripts/load_studies_overlap.sh"
clickhouse-client -m -n < studies_overlap.sql
clickhouse-client -m -n -q "drop table ot.studies_overlap_log;"

echo create dictionaries tables
clickhouse-client -m -n < dictionaries.sql

echo create variants tables
clickhouse-client -m -n < variants_log.sql
bash "${root_path}/scripts/load_variants.sh"
clickhouse-client -m -n < variants.sql
clickhouse-client -m -n -q "drop table ot.variants_log;"

echo create d2v2g tables
clickhouse-client -m -n < d2v2g_log.sql
bash "${root_path}/scripts/load_d2v2g.sh"
clickhouse-client -m -n < d2v2g.sql
clickhouse-client -m -n -q "drop table ot.d2v2g_log;"

echo create v2d tables
clickhouse-client -m -n < v2d_log.sql
bash "${root_path}/scripts/load_v2d.sh"
clickhouse-client -m -n < v2d.sql
clickhouse-client -m -n -q "drop table ot.v2d_log;"

echo create v2g tables
clickhouse-client -m -n < v2g_log.sql
bash "${root_path}/scripts/load_v2g.sh"
clickhouse-client -m -n < v2g.sql
clickhouse-client -m -n -q "drop table ot.v2g_log;"

# elasticsearch process
echo load elasticsearch studies data
export filename="gs://genetics-portal-data/v2d/studies.json"
gsutil cat $filename | elasticsearch_loader --index-settings-file index_settings.json --bulk-size 10000 --index studies --type study json --json-lines -

echo load elasticsearch genes data
export filename="gs://genetics-portal-data/lut/gene_dictionary.json"
gsutil cat $filename | elasticsearch_loader --index-settings-file index_settings.json --bulk-size 10000 --index genes --type gene json --json-lines -

echo load elasticsearch variants data
for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
	chrU=$(echo -n $chr | awk '{print toupper($0)}')
	clickhouse-client -q "select * from ot.variants prewhere chr_id = '${chrU}' format JSONEachRow" | elasticsearch_loader --index-settings-file index_settings.json --bulk-size 10000 --index variant_$chr --type variant json --json-lines -
done



