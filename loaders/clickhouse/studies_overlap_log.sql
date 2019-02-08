create table if not exists ot.studies_overlap_log (
  A_chrom String,
  A_pos UInt32,
  A_ref String,
  A_alt String,
  A_study_id String,
  B_study_id Array(String),
  B_chrom Array(String),
  B_pos Array(UInt32),
  B_ref Array(String),
  B_alt Array(String),
  AB_overlap Array(UInt32),
  A_distinct Array(UInt32),
  B_distinct Array(UInt32)
  )
engine = Log;

