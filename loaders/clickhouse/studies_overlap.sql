create database if not exists ot;
create table if not exists ot.studies_overlap (
  A_chrom String,
  A_pos UInt32,
  A_ref String,
  A_alt String,
  A_study_id String,
  concat(
    cast(A_chrom as String),
    '_',
    cast(A_pos as String),
    '_',
    A_ref,
    '_',
    A_alt
  ) as A_variant_id,
  B_study_id String,
  B_chrom String,
  B_pos UInt32,
  B_ref String,
  B_alt String,
  concat(
    cast(B_chrom as String),
    '_',
    cast(B_pos as String),
    '_',
    B_ref,
    '_',
    B_alt
  ) as B_variant_id,
  AB_overlap UInt32,
  A_distinct UInt32,
  B_distinct UInt32
) engine MergeTree
order by (A_study_id, A_chrom, A_pos, A_ref, A_alt);
insert into ot.studies_overlap
select *
from ot.studies_overlap_log;