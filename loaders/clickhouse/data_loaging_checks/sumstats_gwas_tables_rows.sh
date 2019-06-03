#!/bin/bash

clickhouse_host="${SUMSTATS_CLICKHOUSE_HOST:-localhost}"

for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X" "Y" "MT"; do
    echo ${chr} chromosome rows
	chrn=$(clickhouse-client -h "${clickhouse_host}" --query="select count(*) from sumstats.gwas_chr_${chr};")
    echo ${chrn}
    ovar=$((ovar+chrn))
done
echo overall gwas rows in the log file
clickhouse-client -h "${clickhouse_host}" --query="select count(*) from sumstats.gwas_log;"
echo overall gwas rows
echo ${ovar}
