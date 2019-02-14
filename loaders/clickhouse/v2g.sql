create table if not exists ot.v2g
engine MergeTree partition by (source_id, chr_id) order by (position)
as select
  assumeNotNull(chr_id) as chr_id,
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
  qtl_pval,
  qtl_score,
  interval_score,
  qtl_score_q,
  interval_score_q,
  d,
  distance_score,
  distance_score_q
from ot.v2g_log;

create table if not exists ot.v2g_score_by_source
engine MergeTree partition by (source_id, chr_id) order by (variant_id, gene_id)
as select
  chr_id,
  variant_id,
  gene_id,
  source_id,
  groupArray(feature) as feature_list,
  groupArray(qtl_score_q) as qtl_list,
  groupArray(interval_score_q) as interval_list,
  any(fpred_labels) as fpred_label_list,
  any(fpred_scores) as fpred_score_list,
  max(ifNull(qtl_score_q, 0.)) AS max_qtl,
  max(ifNull(interval_score_q, 0.)) AS max_int,
  max(ifNull(fpred_max_score, 0.)) AS max_fpred,
  max(ifNull(distance_score_q, 0.)) AS max_distance,
  (max_qtl + max_int + max_fpred + max_distance) as source_score,
  source_score * dictGetFloat64('v2gw','weight',tuple(source_id)) as source_score_weighted
from ot.v2g
group by source_id, chr_id, variant_id, gene_id;

create table if not exists ot.v2g_score_by_overall
engine MergeTree partition by (chr_id) order by (variant_id, gene_id)
as select
  chr_id,
  variant_id,
  gene_id,
  groupArray(source_id) as source_list,
  groupArray(source_score) as source_score_list,
  sum(source_score_weighted) / (select sum(weight) from ot.v2gw) as overall_score
from ot.v2g_score_by_source
group by chr_id, variant_id, gene_id;

