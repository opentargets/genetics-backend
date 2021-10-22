create database if not exists ot;
create table if not exists ot.v2g_scored
engine MergeTree partition by (source_id, chr_id) order by (position)
as select
  cast(assumeNotNull(chr_id) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(gene_id) as gene_id,
  assumeNotNull(feature) as feature,
  assumeNotNull(type_id) as type_id,
  assumeNotNull(source_id) as source_id,
  fpred_labels,
  fpred_scores,
  fpred_max_label,
  fpred_max_score,
  qtl_beta,
  qtl_se,
  if (qtl_pval = 0,toFloat64('1E-323'), qtl_pval) as qtl_pval,
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
from (select * from ot.v2g_scored_log where chr_id in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y','MT'));

