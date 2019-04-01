create database if not exists ot;
create table if not exists ot.v2g_scored
  engine MergeTree partition by (source_id, chr_id) order by (position)
as select
     chr_id,
     position,
     ref_allele,
     alt_allele,
     gene_id,
     feature,
     type_id,
     source_id,
     fpred_labels,
     fpred_scores,
     fpred_max_label,
     fpred_max_score,
     qtl_beta,
     qtl_se,
     qtl_pval,
     qtl_score,
     interval_score,
     qtl_score_q,
     interval_score_q,
     d,
     distance_score,
     distance_score_q,
     source_list,
     source_score_list,
     overall_score
   from (
          SELECT
            *
          FROM ot.v2g
          ORDER BY chr_id, position, ref_allele, alt_allele, gene_id
          )
          ALL INNER JOIN (
            SELECT
               *
            FROM ot.v2g_score_by_overall
            ORDER BY chr_id, position, ref_allele, alt_allele, gene_id
          )
          USING (chr_id, position, ref_allele, alt_allele, gene_id);
