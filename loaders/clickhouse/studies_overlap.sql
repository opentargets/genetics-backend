create table if not exists ot.studies_overlap
(
  A_chrom    String,
  A_pos      UInt32,
  A_ref      String,
  A_alt      String,
  A_study_id String,
  overlaps Nested (
    B_study_id String,
    B_chrom String,
    B_pos UInt32,
    B_ref String,
    B_alt String,
    AB_overlap UInt32,
    A_distinct UInt32,
    B_distinct UInt32
    )
)
engine MergeTree order by (A_study_id, A_chrom, A_pos, A_ref, A_alt);
insert into ot.studies_overlap select * from ot.studies_overlap_log;

create table if not exists ot.studies_overlap_exploded
engine MergeTree order by (A_study_id, B_study_id, A_chrom, A_pos, A_ref, A_alt, B_chrom, B_pos, B_ref, B_alt)
as select
  A_chrom,
  A_pos,
  A_ref,
  A_alt,
  A_study_id,
    overlaps.B_study_id as B_study_id,
    overlaps.B_chrom as B_chrom,
    overlaps.B_pos as B_pos,
    overlaps.B_ref as B_ref,
    overlaps.B_alt as B_alt,
    overlaps.AB_overlap as AB_overlap,
    overlaps.A_distinct as A_distinct,
    overlaps.B_distinct as B_distinct
  from ot.studies_overlap array join overlaps;

