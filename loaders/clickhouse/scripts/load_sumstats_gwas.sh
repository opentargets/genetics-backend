#!/usr/bin/env bash

set -x

echo "create database"
clickhouse-client -h otg-clickhouse --query="create database if not exists sumstats"

echo "create Log table for gwas"
clickhouse-client -h otg-clickhouse --query="
create table if not exists sumstats.gwas_log(
    chip String,
    study_id String,
    trait_code String,
    variant_id_b37 String,
    chrom String,
    pos_b37 UInt32,
    segment UInt32 MATERIALIZED (intDiv(pos_b37,1000000)),
    ref_al String,
    alt_al String,
    beta Float64,
    se Float64,
    pval Float64,
    n_samples_variant_level Nullable(UInt32),
    n_samples_study_level Nullable(UInt32),
    n_cases_variant_level Nullable(UInt32),
    n_cases_study_level Nullable(UInt32),
    eaf Nullable(Float64),
    maf Nullable(Float64),
    info Nullable(Float64),
    is_cc String)
engine=Log;
"


echo "Loading all gwas summary stats file by making a recursive, flattened list:"
echo "\n   You might want to check progress with the command: \n "
echo "\n         tail -f done.log \n"
echo "\n   You can also monitor if there are any clickhouse errors in the main logs: \n"
echo "\n         tail /var/log/clickhouse/clickhouse-server.err.log \n"

find $1/gwas/** -type f | tee inputlist.txt | xargs -P 16 -I {} sh -c 'CHIP=`echo {} | cut -d/ -f 5`; STUDY=`echo {} | cut -d/ -f 6`; TRAIT=`echo {} | cut -d/ -f 7`; cat {} | zcat | sed 1d | sed -e "s/^/$CHIP\t$STUDY\t$TRAIT\t/" | clickhouse-client -h otg-clickhouse --query="insert into sumstats.gwas_log format TabSeparated"; echo {} | tee -a done.log;'

# The above imports all empty fields (integers or floats) as zeros rather than
# NULL. It's probably ok for this set, since there should be no zero in the
# input, however another way could be to replace the empties with \N with sed:
# gsutil ls -r gs://genetics-portal-sumstats/gwas/** | xargs -P 16 -I {} sh -c 'CHIP=`echo {} | cut -d/ -f 5`; STUDY=`echo {} | cut -d/ -f 6`; TRAIT=`echo {} | cut -d/ -f 7`; gsutil cat {} | zcat | sed 1d | sed -e "s/^/$CHIP\t$STUDY\t$TRAIT\t/; :0 s/\t\t/\t\\N\t/;t0"  | clickhouse-client -h otg-clickhouse --query="insert into sumstats.gwas_log format TabSeparated"; echo {} >> done.log;'
# do however consider that sed look aheads SLOW the command considerably
# more info at https://github.com/yandex/ClickHouse/issues/469
# sed trickery from: https://stackoverflow.com/questions/30109554/how-do-i-replace-empty-strings-in-a-tsv-with-a-value

echo "all done ... you could check loading is complete by making a file list: \n"
echo '   clickhouse-client -h otg-clickhouse --query="select chip,study_id,trait_code, count(*) from sumstats.gwas_log group by chip, study_id, trait_code format TSV" > log_totals.tsv '

echo "    cat done.tsv | awk -v OFS=',' '{print $4,$2,$3}' | sort | tee done.sorted.tsv | tail"


echo 'see if there are any zeros:'
echo "    awk '{if ($5 = 0) print $0}' < done.tsv"

echo 'compare with the input list:'
echo "    find $1/gwas/genome_wide/** -type f > filelist.tsv"
echo "    cat filelist.tsv| cut -d/ -f 8- | sed 's/-/\t/g; s/.tsv.gz//' | sed 's/\t/,/g' | sort | tee filelist.sorted.tsv | tail"
echo '    comm -23 <(cat filelist.sorted.tsv) <(cat done.sorted.tsv)'

echo 'when you are happy you have everything, run the mergetree scripts'
