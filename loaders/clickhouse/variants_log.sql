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
