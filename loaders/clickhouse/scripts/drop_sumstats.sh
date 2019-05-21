#!/bin/bash

clickhouse_host="${SUMSTATS_CLICKHOUSE_HOST:-localhost}"
echo "drop sumstats database"
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop database sumstats;"
