#!/bin/bash

clickhouse_host="${CLICKHOUSE_HOST:-localhost}"
echo "drop sumstats database"
clickhouse-client -h "${clickhouse_host}" -m -n -q "drop database sumstats;"
