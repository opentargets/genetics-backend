create database if not exists ot;
create table if not exists ot.studies
engine MergeTree order by (study_id)
as select
  assumeNotNull(study_id) as study_id,
  pmid,
  pub_date,
  pub_journal,
  pub_title,
  pub_author,
  has_sumstats,
  trait_reported,
  trait_efos,
  arrayFilter(x -> length(x) > 0, ancestry_initial) as ancestry_initial,
  arrayFilter(x -> length(x) > 0, ancestry_replication) as ancestry_replication,
  n_initial,
  n_replication,
  n_cases,
  trait_category,
  num_assoc_loci
from ot.studies_log;
