create database if not exists ot;
create table if not exists ot.studies_log (
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
  num_assoc_loci Nullable(UInt32))
engine = Log;
