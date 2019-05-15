

for chrom in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT; do
echo $chrom
clickhouse-client -h otg-clickhouse --query="create table if not exists sumstats.gwas_chr_$chrom
engine MergeTree order by (segment, pos_b37)
as select
    cast(assumeNotNull(chip) as Enum8('genome_wide' = 1, 'immunochip' = 2, 'metabochip' = 3 )) as chip,
    assumeNotNull(study_id) as study_id,
    assumeNotNull(trait_code) as trait_code,
    assumeNotNull(variant_id_b37) as variant_id_b37,
    cast(assumeNotNull(chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as chrom,
    assumeNotNull(segment) as segment,
    assumeNotNull(pos_b37) as pos_b37,
    assumeNotNull(ref_al) as ref_al,
    assumeNotNull(alt_al) as alt_al,
    assumeNotNull(beta) as beta,
    assumeNotNull(se) as se,
    assumeNotNull(pval) as pval,
    if(n_samples_variant_level = 0, NULL ,n_samples_variant_level) as n_samples_variant_level,
    if(n_samples_study_level = 0, NULL ,n_samples_study_level) as n_samples_study_level,
    if(n_cases_study_level = 0, NULL ,n_cases_study_level) as n_cases_study_level,
    if(n_cases_variant_level = 0, NULL ,n_cases_variant_level) as n_cases_variant_level,
    if(eaf = 0, NULL ,eaf) as eaf,
    if(maf = 0, NULL ,maf) as maf,
    if(info = 0, NULL ,info) as info,
    if(is_cc = 'True', toUInt8(1), toUInt8(0)) as is_cc
from sumstats.gwas_log
where chrom = '$chrom';
"
sleep 2
done
