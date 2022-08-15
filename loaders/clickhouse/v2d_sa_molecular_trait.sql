create table if not exists ot.v2d_sa_molecular_trait
    engine MergeTree partition by (chrom) order by (chrom, pos)
as
select
       cast(assumeNotNull(type_id) as Enum8('eqtl' = 1, 'pqtl' = 2, 'sqtl' = 3)) as type_id,
       study_id,
       cast(
               assumeNotNull(chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as chrom,
       pos,
       ref,
       alt,
       beta,
       se,
       pval,
       n_total,
       eaf,
       mac,
       num_tests,
       info,
       is_cc,
       phenotype_id,
       gene_id,
       bio_feature
from (
      SELECT *
      FROM ot.v2d_sa_molecular_trait_log
      WHERE pval < 0.005 and chrom IN
            ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13',
             '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y', 'MT')
);

