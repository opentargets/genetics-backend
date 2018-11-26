create database if not exists ot;
create table if not exists ot.d2v2g_log(
  chr_id String,
  position UInt32,
  ref_allele String,
  alt_allele String,
  stid String,
  index_variant_id String,
  r2 Nullable(Float64),
  afr_1000g_prop Nullable(Float64),
  amr_1000g_prop Nullable(Float64),
  eas_1000g_prop Nullable(Float64),
  eur_1000g_prop Nullable(Float64),
  sas_1000g_prop Nullable(Float64),
  log10_abf Nullable(Float64),
  posterior_prob Nullable(Float64),
  pmid Nullable(String),
  pub_date Nullable(String),
  pub_journal Nullable(String),
  pub_title Nullable(String),
  pub_author Nullable(String),
  trait_reported String,
  trait_efos Array(String) default [],
  trait_code String,
  trait_category Nullable(String),
  ancestry_initial Nullable(String),
  ancestry_replication Nullable(String),
  n_initial Nullable(UInt32),
  n_replication Nullable(UInt32),
  n_cases Nullable(UInt32),
  pval Float64,
  index_variant_rsid String,
  index_chr_id String,
  index_position UInt32,
  index_ref_allele String,
  index_alt_allele String,
  variant_id String,
  rs_id String,
  gene_chr String,
  gene_id String,
  gene_start UInt32,
  gene_end UInt32,
  gene_type String,
  gene_name String,
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
  interval_score_q Nullable(Float64)
)
engine = Log;
