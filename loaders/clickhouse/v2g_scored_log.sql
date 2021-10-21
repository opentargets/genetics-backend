create database if not exists ot;
create table if not exists ot.v2g_scored_log(
  chr_id String,
  position UInt32,
  ref_allele String,
  alt_allele String,
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

