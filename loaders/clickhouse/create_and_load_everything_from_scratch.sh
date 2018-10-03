#!/bin/bash

root_path=$(pwd)

echo create studies tables
clickhouse-client -m -n < studies_log.sql
bash "${root_path}/scripts/load_studies.sh"
clickhouse-client -m -n < studies.sql
clickhouse-client -m -n -q "drop table ot.studies_log;"

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
echo load elasticsearch genes data
echo load elasticsearch variants data


