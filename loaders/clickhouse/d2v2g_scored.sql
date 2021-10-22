create database if not exists ot;
create table if not exists ot.d2v2g_scored
  engine MergeTree partition by (lead_chrom) order by (lead_pos, lead_ref, lead_alt, gene_id)
as select
     study_id,
     pmid,
     pub_date,
     pub_journal,
     pub_title,
     pub_author,
     has_sumstats,
     trait_reported,
     trait_efos,
     ancestry_initial,
     ancestry_replication,
     n_initial,
     n_replication,
     n_cases,
     trait_category,
     num_assoc_loci,
     cast(assumeNotNull(lead_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as lead_chrom,
     lead_pos,
     lead_ref,
     lead_alt,
     cast(assumeNotNull(tag_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as tag_chrom,
     tag_pos,
     tag_ref,
     tag_alt,
     overall_r2 ,
     AFR_1000G_prop ,
     AMR_1000G_prop ,
     EAS_1000G_prop ,
     EUR_1000G_prop ,
     SAS_1000G_prop ,
     log10_ABF ,
     posterior_prob ,
     odds_ratio ,
     oddsr_ci_lower ,
     oddsr_ci_upper ,
     direction ,
     beta ,
     beta_ci_lower ,
     beta_ci_upper ,
     pval_mantissa ,
     pval_exponent ,
     pval ,
     assumeNotNull(gene_id) as gene_id,
     assumeNotNull(feature) as feature,
     assumeNotNull(type_id) as type_id,
     assumeNotNull(source_id) as source_id,
     fpred_labels ,
     fpred_scores ,
     fpred_max_label ,
     fpred_max_score ,
     qtl_beta ,
     qtl_se ,
     qtl_pval ,
     qtl_score ,
     interval_score ,
     qtl_score_q ,
     interval_score_q ,
     d ,
     distance_score ,
     distance_score_q ,
     source_list,
     source_score_list,
     overall_score
   from (SELECT * FROM ot.d2v2g_scored_log where tag_chrom in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y','MT') ) T;

