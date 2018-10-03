drop table ot.studies;
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
from ot.studies_log;
