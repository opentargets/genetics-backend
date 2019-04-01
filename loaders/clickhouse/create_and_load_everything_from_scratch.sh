#!/bin/bash

# CURRENTLY, IN ORDER TO BUILD SOME TABLES WE NEED A HIGHMEM MACHINE

root_path=$(pwd)
base_path="gs://genetics-portal-output/190301"
echo "loading file ${filename}"

echo create genes table
clickhouse-client -m -n < genes.sql
gsutil cat "${base_path}/lut/genes-index/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.genes format JSONEachRow "

echo create studies tables
clickhouse-client -m -n < studies_log.sql
gsutil cat "${base_path}/lut/study-index/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.studies_log format JSONEachRow "
clickhouse-client -m -n < studies.sql
clickhouse-client -m -n -q "drop table ot.studies_log;"

echo create studies overlap tables
clickhouse-client -m -n < studies_overlap_log.sql
gsutil cat "${base_path}/lut/overlap-index/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.studies_overlap_log format JSONEachRow "
clickhouse-client -m -n < studies_overlap.sql
clickhouse-client -m -n -q "drop table ot.studies_overlap_log;"

echo create dictionaries tables
clickhouse-client -m -n < dictionaries.sql

echo create variants tables
clickhouse-client -m -n < variants_log.sql
gsutil cat "${base_path}/lut/variant-index/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.variants_log format JSONEachRow "
clickhouse-client -m -n < variants.sql
clickhouse-client -m -n -q "drop table ot.variants_log;"

echo create d2v2g tables
clickhouse-client -m -n < d2v2g_log.sql
gsutil cat "${base_path}/d2v2g/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.d2v2g_log format JSONEachRow "
clickhouse-client -m -n < d2v2g.sql
clickhouse-client -m -n -q "drop table ot.d2v2g_log;"

echo create v2d tables
clickhouse-client -m -n < v2d_log.sql
gsutil cat "${base_path}/v2d/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2d_log format JSONEachRow "
clickhouse-client -m -n < v2d.sql
clickhouse-client -m -n -q "drop table ot.v2d_log;"

echo create v2g tables
clickhouse-client -m -n < v2g_log.sql
gsutil cat "${base_path}/v2g/part-*" | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2g_log format JSONEachRow "
clickhouse-client -m -n < v2g.sql
clickhouse-client -m -n -q "drop table ot.v2g_log;"

echo create v2g structure
clickhouse-client -m -n < v2g_structure.sql

#echo compute v2g_scored table
#clickhouse-client -m -n < v2g_scored.sql

echo compute d2v2g_scored table
clickhouse-client -m -n < d2v2g_scored.sql

echo compute locus 2 gene table
clickhouse-client -m -n < d2v2g_scored_l2g.sql

# elasticsearch process
echo load elasticsearch studies data
curl -XDELETE localhost:9200/studies
gsutil cat "${base_path}/lut/study-index/part-*" | elasticsearch_loader --index-settings-file index_settings_studies.json --bulk-size 10000 --index studies --type study json --json-lines -

echo load elasticsearch genes data
curl -XDELETE localhost:9200/genes
gsutil cat "${base_path}/lut/genes-index/part-*" | elasticsearch_loader --index-settings-file index_settings_genes.json --bulk-size 10000 --index genes --type gene json --json-lines -

echo load elasticsearch variants data
for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
	chrU=$(echo -n $chr | awk '{print toupper($0)}')
	curl -XDELETE localhost:9200/variant_$chr
	clickhouse-client -q "select * from ot.variants prewhere chr_id = '${chrU}' format JSONEachRow" | elasticsearch_loader --index-settings-file index_settings_variants.json --bulk-size 10000 --index variant_$chr --type variant json --json-lines -
done



