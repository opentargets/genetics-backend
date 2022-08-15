create database if not exists ot;
create table if not exists ot.variants
engine MergeTree order by (variant_id)
as select
  cast(assumeNotNull(chr_id) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as chr_id,
  cast(assumeNotNull(chr_id_b37) as Enum8('1' = 1, '2' = 2, '3' = 3, '4' = 4, '5' = 5, '6' = 6, '7' = 7, '8' = 8, '9' = 9, '10' = 10, '11' = 11, '12' = 12, '13' = 13, '14' = 14, '15' = 15, '16' = 16, '17' = 17, '18' = 18, '19' = 19, '20' = 20, '21' = 21, '22' = 22, 'X'= 23, 'Y' = 24, 'MT'=25 )) as chr_id_b37,
  assumeNotNull(position) as position,
  assumeNotNull(position_b37) as position_b37,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  concat(toString(chr_id),'_',toString(position),'_',ref_allele,'_',alt_allele) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  gene_id_any,
  gene_id_any_distance,
  gene_id_prot_coding_distance,
  gene_id_prot_coding,
  most_severe_consequence,
  raw,
  phred,
  gnomad_afr,
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
from (select * from ot.variants_log where chr_id in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 'X', 'Y','MT'));
