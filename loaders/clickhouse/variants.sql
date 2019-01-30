create table if not exists ot.variants
engine MergeTree partition by (chr_id, segment) order by (variant_id)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  segment,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  gene_id,
  gene_id_prot_coding,
  most_severe_consequence,
  raw,
  phred,
  gnomad_afr,
  gnomad_seu,
  gnomad_amr,
  gnomad_asj,
  gnomad_eas,
  gnomad_fin,
  gnomad_nfe,
  gnomad_nfe_est,
  gnomad_nfe_seu,
  gnomad_nfe_nwe,
  gnomad_nfe_onf,
  gnomad_oth
from ot.variants_log;

