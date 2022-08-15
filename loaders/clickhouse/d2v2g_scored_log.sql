create database if not exists ot;
create table if not exists ot.d2v2g_scored_log(
  study_id String,
  source String,
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
  num_assoc_loci Nullable(UInt32),
  lead_chrom String,
  lead_pos UInt32,
  lead_ref String,
  lead_alt String,
  tag_chrom String,
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
  distance_score_q Nullable(Float64),
  source_list Array(String) default [],
  source_score_list Array(Float64) default [],
  overall_score Float64)
engine = Log;

