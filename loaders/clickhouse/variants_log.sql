create database if not exists ot;
create table if not exists ot.variants_log (
  chr_id String,
  position UInt32,
  chr_id_b37 String,
  position_b37 UInt32,
  ref_allele String,
  alt_allele String,
  rs_id Nullable(String),
  gene_id_prot_coding Nullable(String),
  gene_id_any Nullable(String),
  gene_id_any_distance Nullable(UInt32),
  gene_id_prot_coding_distance Nullable(UInt32),
  most_severe_consequence Nullable(String),
  raw Nullable(Float64),
  phred Nullable(Float64),
  gnomad_afr Nullable(Float64),
  gnomad_amr Nullable(Float64),
  gnomad_asj Nullable(Float64),
  gnomad_eas Nullable(Float64),
  gnomad_fin Nullable(Float64),
  gnomad_nfe Nullable(Float64),
  gnomad_nfe_est Nullable(Float64),
  gnomad_nfe_seu Nullable(Float64),
  gnomad_nfe_nwe Nullable(Float64),
  gnomad_nfe_onf Nullable(Float64),
  gnomad_oth Nullable(Float64)
  )
engine = Log;
