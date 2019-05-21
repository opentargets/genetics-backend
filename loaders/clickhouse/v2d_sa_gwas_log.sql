create database if not exists ot;
create table if not exists ot.v2d_sa_gwas_log(
  type String,
  study_id String,
  chrom String,
  pos UInt32,
  ref String,
  alt String,
  eaf Float64,
  mac Float64,
  mac_cases Float64,
  info Float64,
  beta Float64,
  se Float64,
  pval Float64,
  n_total UInt32,
  n_cases UInt32,
  is_cc UInt8)
engine = Log;