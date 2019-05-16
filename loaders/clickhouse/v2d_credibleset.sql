create database if not exists ot;
create table if not exists ot.v2d_credset
    engine MergeTree
        partition by (lead_chrom)
        order by (lead_pos, lead_ref, lead_alt, study_id, tag_pos, tag_ref, tag_alt)
as select
    study_id,
    cast(assumeNotNull(lead_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as lead_chrom,
    lead_pos,
    lead_ref,
    lead_alt,
    cast(assumeNotNull(tag_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as tag_chrom,
    tag_pos,
    tag_ref,
    tag_alt,
    bio_feature,
    is95_credset,
    is99_credset,
    logABF,
    multisignal_method,
    phenotype_id,
    postprob,
    postprob_cumsum,
    tag_beta,
    tag_beta_cond,
    tag_pval,
    tag_pval_cond,
    tag_se,
    tag_se_cond,
    cast(assumeNotNull(type) as Enum8('eqtl' = 1, 'pqtl' = 2, 'gwas' = 3)) as data_type
from ot.v2d_credset_log;

