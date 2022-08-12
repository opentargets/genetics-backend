create database if not exists ot;
create table if not exists ot.v2d_coloc
    engine MergeTree
        partition by (left_chrom)
        order by (left_chrom, left_pos, left_ref, left_alt, left_study, right_pos, right_ref, right_alt, right_study)
as select
    coloc_h0,
    coloc_h1,
    coloc_h2,
    coloc_h3,
    coloc_h4,
    cast(assumeNotNull(left_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as left_chrom,
    left_pos,
    left_ref,
    left_alt,
    left_study,
    cast(assumeNotNull(left_type) as Enum8('eqtl' = 1, 'pqtl' = 2, 'gwas' = 3, 'sqtl' = 4)) as left_type,
    coloc_n_vars,
    cast(assumeNotNull(right_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as right_chrom,
    right_pos,
    right_ref,
    right_alt,
    right_study,
    cast(assumeNotNull(right_type) as Enum8('eqtl' = 1, 'pqtl' = 2, 'gwas' = 3, 'sqtl' = 4)) as right_type,
    coloc_h4_h3,
    coloc_log2_h4_h3,
    is_flipped,
    right_gene_id,
    right_bio_feature,
    right_phenotype,
    left_var_right_study_beta,
    left_var_right_study_se,
    left_var_right_study_pval,
    left_var_right_isCC
from (select * from ot.v2d_coloc_log where left_chrom in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y','MT') and
                                           right_chrom in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y','MT') and
                                           coloc_n_vars >= 200
     );
