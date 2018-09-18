-- Manhattan plot is one study across all variants all diseases we use the v2d table as
--  it is a filtered version
-- Phewas plot is one variant one chromosome all diseases (studies)
-- regional plot is one variant one chromosome all diseases but using summary stats
-- so we must create two main tables from v2d data: v2d_by_d from v2d_sa (from summary stats)
-- and v2d_by_chrpos from v2d

create database if not exists ot;
create table if not exists ot.v2d_log(
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
  rs_id String)
engine = Log;

create table if not exists ot.v2d_by_chrpos
engine MergeTree partition by (chr_id) order by (chr_id, position)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(stid) as stid,
  assumeNotNull(index_variant_id) as index_variant_id,
  r2,
  afr_1000g_prop,
  amr_1000g_prop,
  eas_1000g_prop,
  eur_1000g_prop,
  sas_1000g_prop,
  log10_abf,
  posterior_prob,
  pmid,
  pub_date,
  pub_journal,
  pub_title,
  pub_author,
  trait_reported,
  trait_efos,
  trait_code,
  ancestry_initial,
  ancestry_replication,
  n_initial,
  n_replication,
  n_cases,
  assumeNotNull(if(pval = 0.,toFloat64('4.9e-323') ,pval )) as pval,
  assumeNotNull(index_variant_rsid) as index_rs_id,
  assumeNotNull(index_chr_id) as index_chr_id,
  assumeNotNull(index_position) as index_position,
  assumeNotNull(index_ref_allele) as index_ref_allele,
  assumeNotNull(index_alt_allele) as index_alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id
from ot.v2d_log;

create table if not exists ot.v2d_by_stchr
engine MergeTree partition by (chr_id) order by (stid, chr_id, position)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(stid) as stid,
  assumeNotNull(index_variant_id) as index_variant_id,
  r2,
  afr_1000g_prop,
  amr_1000g_prop,
  eas_1000g_prop,
  eur_1000g_prop,
  sas_1000g_prop,
  log10_abf,
  posterior_prob,
  pmid,
  pub_date,
  pub_journal,
  pub_title,
  pub_author,
  trait_reported,
  trait_efos,
  trait_code,
  ancestry_initial,
  ancestry_replication,
  n_initial,
  n_replication,
  n_cases,
  assumeNotNull(if(pval = 0.,toFloat64('4.9e-323') ,pval )) as pval,
  assumeNotNull(index_variant_rsid) as index_rs_id,
  assumeNotNull(index_chr_id) as index_chr_id,
  assumeNotNull(index_position) as index_position,
  assumeNotNull(index_ref_allele) as index_ref_allele,
  assumeNotNull(index_alt_allele) as index_alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id
from ot.v2d_log;


-- create studies table from TSV insert
create table if not exists ot.studies_temp (
study_id              String,
pmid                  Nullable(String),
pub_date              String,
pub_journal           Nullable(String),
pub_title             Nullable(String),
pub_author            String,
trait_reported        String,
trait_efos            Nullable(String),
trait_code            String,
ancestry_initial      Nullable(String),
ancestry_replication  Nullable(String),
n_initial             Nullable(UInt32),
n_replication         Nullable(UInt32),
n_cases               Nullable(Float64),
trait_category        Nullable(String)
) Engine = TinyLog;
-- gsutil cat gs://genetics-portal-data/v2d/studies.tsv | clickhouse-client -h 127.0.0.1 --query="insert into ot.studies_temp format TabSeparatedWithNames"


create table ot.studies
engine = Memory
as select
study_id,
pmid,
toDate(pub_date) as pub_date,
pub_journal,
pub_title,
pub_author,
trait_reported,
trait_efos,
trait_code,
ancestry_initial,
ancestry_replication,
n_initial,
n_replication,
toUInt32(n_cases) as n_cases,
trait_category
from ot.studies_temp;