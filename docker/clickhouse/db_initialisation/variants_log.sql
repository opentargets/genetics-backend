create database if not exists ot;
create table if not exists ot.variants_log (
  chr_id String,
  position UInt32,
  chr_id_b37 String,
  position_b37 UInt32,
  ref_allele String,
  alt_allele String,
  rs_id String,
  gene_id_prot_coding String,
  gene_id_any String,
  gene_id_any_distance UInt32,
  gene_id_prot_coding_distance UInt32,
  most_severe_consequence String,
  raw Float64,
  phred Float64,
  gnomad_afr Float64,
  gnomad_seu Float64,
  gnomad_amr Float64,
  gnomad_asj Float64,
  gnomad_eas Float64,
  gnomad_fin Float64,
  gnomad_nfe Float64,
  gnomad_nfe_est Float64,
  gnomad_nfe_seu Float64,
  gnomad_nfe_nwe Float64,
  gnomad_nfe_onf Float64,
  gnomad_oth Float64
  )
engine = Log;
