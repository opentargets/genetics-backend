create database if not exists ot;
create table if not exists ot.variants_log (
  chr_id String,
  position UInt32,
  ref_allele String,
  alt_allele String,
  variant_id String,
  rs_id String,
  gene_id_prot_coding String,
  gene_id String)
engine = Log;

create table if not exists ot.variants
engine MergeTree partition by (chr_id) order by (position)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  gene_id_prot_coding,
  gene_id
from ot.variants_log;

