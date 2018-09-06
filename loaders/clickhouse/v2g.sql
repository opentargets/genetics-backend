-- a good idea is to include the source_name in order to partition by (chr_id and source_name)

-- generate quantiles using clickhouse
-- create materialized view ot.v2g_quantiles engine=Memory populate as select
--  source_id, feature,
--  quantilesIf(0.10, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)(1 - qtl_pval, qtl_pval > 0) as qtl_quantiles,
--  quantilesIf(0.10, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)(interval_score, qtl_pval = 0) as interval_quantiles
-- from ot.v2g
-- where source_id <> 'vep'
-- group by source_id, feature

-- drop and create the table in the case it exists
create database if not exists ot;
create table if not exists ot.v2g_log(
  chr_id String,
  position UInt32,
  segment UInt32 MATERIALIZED (position % 1000000),
  ref_allele String,
  alt_allele String,
  variant_id String,
  rs_id String,
  gene_chr String,
  gene_id String,
  gene_start UInt32,
  gene_end UInt32,
  gene_type String,
  gene_name String,
  feature String,
  type_id String,
  source_id String,
  fpred_labels Array(String) default [],
  fpred_scores Array(Float64)default [],
  fpred_max_label Nullable(String),
  fpred_max_score Nullable(Float64),
  qtl_beta Nullable(Float64),
  qtl_se Nullable(Float64),
  qtl_pval Nullable(Float64),
  qtl_score Nullable(Float64),
  interval_score Nullable(Float64),
  qtl_score_q Nullable(Float64),
  interval_score_q Nullable(Float64))
engine = Log;

-- how insert the data from files into the log db
-- insert into ot.v2g_log format TabSeparatedWithNames from '/opt/out/v2g/*.json';
-- for line in $(cat list_files.txt); do
--  gsutil cat $line | clickhouse-client -h 127.0.0.1 --query="insert into ot.v2g_log format TabSeparatedWithNames ";
-- done

-- main v2g table with proper mergetree engine
-- maybe partition by chr_id and source_id
create table if not exists ot.v2g
engine MergeTree partition by (source_id, chr_id) order by (position)
as select
  assumeNotNull(chr_id) as chr_id,
  assumeNotNull(position) as position,
  assumeNotNull(segment) as segment,
  assumeNotNull(ref_allele) as ref_allele,
  assumeNotNull(alt_allele) as alt_allele,
  assumeNotNull(variant_id) as variant_id,
  assumeNotNull(rs_id) as rs_id,
  assumeNotNull(gene_chr) as gene_chr,
  assumeNotNull(gene_id) as gene_id,
  assumeNotNull(gene_start) as gene_start,
  assumeNotNull(gene_end) as gene_end,
  assumeNotNull(gene_type) as gene_type,
  assumeNotNull(gene_name) as gene_name,
  assumeNotNull(feature) as feature,
  assumeNotNull(type_id) as type_id,
  assumeNotNull(source_id) as source_id,
  fpred_labels,
  fpred_scores,
  fpred_max_label,
  fpred_max_score,
  qtl_beta,
  qtl_se,
  qtl_pval,
  qtl_score,
  interval_score,
  qtl_score_q,
  interval_score_q
from ot.v2g_log;

create table if not exists ot.v2g_score_by_source
engine MergeTree partition by (source_id, chr_id) order by (variant_id, gene_id)
as select
  chr_id,
  variant_id,
  gene_id,
  source_id,
  groupArray(feature) as feature_list,
  groupArray(qtl_score_q) as qtl_list,
  groupArray(interval_score_q) as interval_list,
  any(fpred_labels) as fpred_label_list,
  any(fpred_scores) as fpred_score_list,
  max(ifNull(qtl_score_q, 0.)) AS max_qtl,
  max(ifNull(interval_score_q, 0.)) AS max_int,
  max(ifNull(fpred_max_score, 0.)) AS max_fpred,
  max_qtl + max_int + max_fpred as source_score
from ot.v2g
group by source_id, chr_id, variant_id, gene_id

-- generate a list of overall scores
create table if not exists ot.v2g_score_by_overall
engine MergeTree partition by (chr_id) order by (variant_id, gene_id)
as select
  chr_id,
  variant_id,
  gene_id,
  groupArray(source_id) as source_list,
  groupArray(source_score) as source_score_list,
  avg(source_score) as overall_score
from ot.v2g_score_by_source
group by chr_id, variant_id, gene_id

-- generate list of tissues
create materialized view ot.v2g_structure
engine=Memory populate as
SELECT 
    type_id,
    source_id,
    groupUniqArray(feature) AS feature_set,
    length(feature_set) AS feature_set_size
FROM ot.v2g
WHERE chr_id = '1'
GROUP BY 
    type_id,
    source_id
ORDER BY 
    type_id ASC,
    source_id ASC,
    feature_set ASC

