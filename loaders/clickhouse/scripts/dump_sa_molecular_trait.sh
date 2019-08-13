#!/usr/bin/env bash

export SUMSTATS_CLICKHOUSE_HOST="${SUMSTATS_CLICKHOUSE_HOST:-localhost}"

for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X" "Y" "MT"; do
    clickhouse-client -h "${SUMSTATS_CLICKHOUSE_HOST}" --query="select toString(type_id) as type_id, study_id, toString(chrom) as chrom, pos, ref, alt, eaf, mac, num_tests, info, beta, se, pval, n_total, is_cc, phenotype_id, gene_id, bio_feature from ot.v2d_sa_molecular_trait where chrom = '${chr}' format Parquet" > "ot_v2d_sa_molecular_trait_${chr}.parquet"
done
