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

