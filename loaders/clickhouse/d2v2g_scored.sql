create database if not exists ot;
create table if not exists ot.d2v2g_scored
  engine MergeTree partition by (source_id, tag_chrom) order by (tag_pos)
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
     lead_chrom,
     lead_pos,
     lead_ref,
     lead_alt,
     tag_chrom,
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
     gene_id ,
     feature ,
     type_id ,
     source_id ,
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
   from (
          SELECT
            *
          FROM ot.d2v2g
          ORDER BY tag_chrom, tag_pos, tag_ref, tag_alt, gene_id
          )
    ALL INNER JOIN (
     SELECT
       *
     FROM ot.d2v2g_score_by_overall
     ORDER BY tag_chrom, tag_pos, tag_ref, tag_alt, gene_id
    ) USING (tag_chrom, tag_pos, tag_ref, tag_alt, gene_id);

create database if not exists ot;
create table if not exists ot.d2v2g_scored_agg
  engine MergeTree partition by (chrom)
      order by (study, chrom, pos, ref, alt)
as select
          study,
          chrom,
          pos,
          ref,
          alt,
          top10_genes as top10_genes,
          agg_type
          from (
                select
                       study_id as study,
                       lead_chrom as chrom,
                       lead_pos as pos,
                       lead_ref as ref,
                       lead_alt as alt,
                       arraySlice(
                           arrayReverseSort(
                               arrayReduce('groupUniqArray',
                                   groupArray((overall_score, gene_id)))),1,10) AS top10_genes,
                    'raw' as agg_type
                from ot.d2v2g_scored
               group by study_id,
                        lead_chrom,
                        lead_pos,
                        lead_ref,
                        lead_alt
            );
