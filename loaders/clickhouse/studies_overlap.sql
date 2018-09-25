create table if not exists ot.studies_overlap_log(
  index_variantid_b37_A String,
  index_variantid_b37_B String,
  set_type String,
  study_id_A String,
  study_id_B String,
  overlap_AB UInt32,
  distinct_A UInt32,
  distinct_B UInt32)
engine = Log;

create table if not exists ot.studies_overlap
engine MergeTree Partition by (study_id_a) order by (index_variant_id_a, index_variant_id_b)
as select
  assumeNotNull(study_id_A) as study_id_a,
  assumeNotNull(study_id_B) as study_id_b,
  assumeNotNull(set_type) as set_type,
  assumeNotNull(index_variantid_b37_A) as index_variant_id_a,
  assumeNotNull(index_variantid_b37_B) as index_variant_id_b,
  overlap_AB,
  distinct_A,
  distinct_B
from ot.studies_overlap_log
