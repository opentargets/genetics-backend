create table if not exists ot.variants
engine MergeTree partition by (chr_id) order by (variant_id)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  gene_id,
  gene_id_prot_coding
from ot.variants_log;

