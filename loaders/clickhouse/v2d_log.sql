create database if not exists ot;
create table if not exists ot.v2d_log(
  study_id String,
  pmid Nullable(String),
  pub_date Nullable(String),
  pub_journal Nullable(String),
  pub_title Nullable(String),
  pub_author Nullable(String),
  trait_reported String,
  trait_efos Array(String) default [],
  ancestry_initial Array(String) default [],
  ancestry_replication Array(String) default [],
  n_initial Nullable(UInt32),
  n_replication Nullable(UInt32),
  n_cases Nullable(UInt32),
  trait_category Nullable(String),
  num_assoc_loci Nullable(UInt32),
  B_study_id Array(String),
  B_chrom Array(String),
  B_pos Array(UInt32),
  B_ref Array(String),
  B_alt Array(String),
  AB_overlap Array(UInt32),
  A_distinct Array(UInt32),
  B_distinct Array(UInt32),
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
  odds_ratio Float64,
  oddsr_ci_lower Float64,
  oddsr_ci_upper Float64,
  direction String,
  beta Float64,
  beta_ci_lower Float64,
  beta_ci_upper Float64,
  pval_mantissa Float64,
  pval_exponent Int32,
  pval Float64)
engine = Log;

