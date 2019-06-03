#!/bin/bash

clickhouse_host="${CLICKHOUSE_HOST:-localhost}"

echo genes
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.genes;"
echo studies
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.studies;"
echo overlaps
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.studies_overlap;"
echo variants
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.variants;"
echo d2v2g
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.d2v2g;"
echo v2d
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.v2d_by_chrpos;"
echo v2d str chr
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.v2d_by_stchr;"
echo v2g
clickhouse-client -h "${clickhouse_host}" -m -n -q "select count(*) from ot.v2g;"
