create table if not exists ot.v2g
engine MergeTree partition by (source_id, chr_id) order by (position)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  assumeNotNull(gene_chr) as gene_chr,
  assumeNotNull(gene_id) as gene_id,
  assumeNotNull(gene_start) as gene_start,
  assumeNotNull(gene_end) as gene_end,
  assumeNotNull(gene_type) as gene_type,
  assumeNotNull(gene_name) as gene_name,
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
  interval_score_q
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
  (max_qtl + max_int + max_fpred) as source_score,
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

create materialized view ot.v2g_structure
engine=Memory populate as
SELECT 
    type_id,
    source_id,
    groupUniqArray(feature) AS feature_set,
    length(feature_set) AS feature_set_size
FROM ot.v2g
WHERE chr_id = '1'
GROUP BY 
    type_id,
    source_id
ORDER BY 
    type_id ASC,
    source_id ASC,
    feature_set ASC;

