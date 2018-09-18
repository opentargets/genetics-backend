create table if not exists ot.studies_log(
  study_id String,
  pmid Nullable(String),
  pub_date Nullable(String),
  pub_journal Nullable(String),
  pub_title Nullable(String),
  pub_author Nullable(String),
  trait_reported String,
  trait_efos Array(String) default [],
  trait_code String,
  ancestry_initial Array(String) default [],
  ancestry_replication Array(String) default [],
  n_initial Nullable(UInt32),
  n_replication Nullable(UInt32),
  n_cases Nullable(UInt32),
  trait_category Nullable(String))
engine = Log;

create table if not exists ot.studies
engine Memory
as select
  assumeNotNull(study_id) as study_id,
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
  trait_category
from ot.studies_log
