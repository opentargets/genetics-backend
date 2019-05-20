create database if not exists ot;
create table if not exists ot.d2v2g(
  study_id String,
  pmid Nullable(String),
  pub_date Nullable(String),
  pub_journal Nullable(String),
  pub_title Nullable(String),
  pub_author Nullable(String),
  has_sumstats UInt8,
  trait_reported String,
  trait_efos Array(String) default [],
  ancestry_initial Array(String) default [],
  ancestry_replication Array(String) default [],
  n_initial Nullable(UInt32),
  n_replication Nullable(UInt32),
  n_cases Nullable(UInt32),
  trait_category Nullable(String),
  num_assoc_loci Nullable(UInt32),
  cast(assumeNotNull(lead_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as lead_chrom,
  lead_pos UInt32,
  lead_ref String,
  lead_alt String,
  cast(assumeNotNull(tag_chrom) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as tag_chrom,
  tag_pos UInt32,
  tag_ref String,
  tag_alt String,
  overall_r2 Nullable(Float64),
  AFR_1000G_prop Nullable(Float64),
  AMR_1000G_prop Nullable(Float64),
  EAS_1000G_prop Nullable(Float64),
  EUR_1000G_prop Nullable(Float64),
  SAS_1000G_prop Nullable(Float64),
  log10_ABF Nullable(Float64),
  posterior_prob Nullable(Float64),
  odds_ratio Nullable(Float64),
  oddsr_ci_lower Nullable(Float64),
  oddsr_ci_upper Nullable(Float64),
  direction Nullable(String),
  beta Nullable(Float64),
  beta_ci_lower Nullable(Float64),
  beta_ci_upper Nullable(Float64),
  pval_mantissa Float64,
  pval_exponent Int32,
  pval Float64,
  gene_id String,
  feature String,
  type_id String,
  source_id String,
  fpred_labels Array(String) default [],
  fpred_scores Array(Float64)default [],
  fpred_max_label Nullable(String),
  fpred_max_score Nullable(Float64),
  qtl_beta Nullable(Float64),
  qtl_se Nullable(Float64),
  qtl_pval Nullable(Float64),
  qtl_score Nullable(Float64),
  interval_score Nullable(Float64),
  qtl_score_q Nullable(Float64),
  interval_score_q Nullable(Float64),
  d Nullable(UInt32),
  distance_score Nullable(Float64),
  distance_score_q Nullable(Float64)
)
engine MergeTree partition by (source_id, tag_chrom) order by (tag_pos);

insert into ot.d2v2g select * from ot.d2v2g_log;

create table if not exists ot.d2v2g_score_by_source
engine MergeTree partition by (source_id, tag_chrom) order by (tag_chrom, tag_pos, tag_ref, tag_alt, gene_id)
as select
  tag_chrom,
  tag_pos,
  tag_ref,
  tag_alt,
  gene_id,
  source_id,
  groupArray(feature) as feature_list,
  groupArray(qtl_score_q) as qtl_list,
  groupArray(interval_score_q) as interval_list,
  groupArray(distance_score_q) as distance_list,
  any(fpred_labels) as fpred_label_list,
  any(fpred_scores) as fpred_score_list,
  max(ifNull(qtl_score_q, 0.)) AS max_qtl,
  max(ifNull(interval_score_q, 0.)) AS max_int,
  max(ifNull(fpred_max_score, 0.)) AS max_fpred,
  max(ifNull(distance_score_q, 0.)) AS max_distance,
  (max_qtl + max_int + max_fpred + max_distance) as source_score,
  source_score * dictGetFloat64('v2gw','weight',tuple(source_id)) as source_score_weighted
from ot.d2v2g
group by source_id, tag_chrom, tag_pos, tag_ref, tag_alt, gene_id;

create table if not exists ot.d2v2g_score_by_overall
engine MergeTree partition by (tag_chrom) order by (tag_chrom, tag_pos, tag_ref, tag_alt, gene_id)
as select
  tag_chrom,
  tag_pos,
  tag_ref,
  tag_alt,
  gene_id,
  groupArray(source_id) as source_list,
  groupArray(source_score) as source_score_list, 
  sum(source_score_weighted) / (select sum(weight) from ot.v2gw) as overall_score
from ot.d2v2g_score_by_source
group by tag_chrom, tag_pos, tag_ref, tag_alt, gene_id;

