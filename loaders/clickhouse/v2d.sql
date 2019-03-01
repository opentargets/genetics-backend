create database if not exists ot;
create table if not exists ot.v2d_by_chrpos(
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
engine MergeTree partition by (lead_chrom) order by (lead_pos, lead_ref, lead_alt);

create table if not exists ot.v2d_by_stchr(
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
engine MergeTree partition by (lead_chrom) order by (study_id, lead_pos, lead_ref, lead_alt);

insert into ot.v2d_by_chrpos
select
  study_id ,
  pmid ,
  pub_date ,
  pub_journal ,
  pub_title ,
  pub_author ,
  trait_reported ,
  trait_efos ,
  ancestry_initial ,
  ancestry_replication ,
  n_initial ,
  n_replication ,
  n_cases ,
  trait_category ,
  num_assoc_loci ,
  lead_chrom ,
  lead_pos ,
  lead_ref ,
  lead_alt ,
  tag_chrom ,
  tag_pos ,
  tag_ref ,
  tag_alt ,
  overall_r2 ,
  AFR_1000G_prop ,
  AMR_1000G_prop ,
  EAS_1000G_prop ,
  EUR_1000G_prop ,
  SAS_1000G_prop ,
  log10_ABF ,
  posterior_prob ,
  odds_ratio ,
  oddsr_ci_lower ,
  oddsr_ci_upper ,
  direction ,
  beta ,
  beta_ci_lower ,
  beta_ci_upper ,
  pval_mantissa ,
  pval_exponent ,
  pval
from ot.v2d_log;
insert into ot.v2d_by_stchr
select
       study_id ,
  pmid ,
  pub_date ,
  pub_journal ,
  pub_title ,
  pub_author ,
  trait_reported ,
  trait_efos ,
  ancestry_initial ,
  ancestry_replication ,
  n_initial ,
  n_replication ,
  n_cases ,
  trait_category ,
  num_assoc_loci ,
  lead_chrom ,
  lead_pos ,
  lead_ref ,
  lead_alt ,
  tag_chrom ,
  tag_pos ,
  tag_ref ,
  tag_alt ,
  overall_r2 ,
  AFR_1000G_prop ,
  AMR_1000G_prop ,
  EAS_1000G_prop ,
  EUR_1000G_prop ,
  SAS_1000G_prop ,
  log10_ABF ,
  posterior_prob ,
  odds_ratio ,
  oddsr_ci_lower ,
  oddsr_ci_upper ,
  direction ,
  beta ,
  beta_ci_lower ,
  beta_ci_upper ,
  pval_mantissa ,
  pval_exponent ,
  pval
from ot.v2d_log;
