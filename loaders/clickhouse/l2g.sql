create database if not exists ot;
create table if not exists ot.l2g_by_slg engine MergeTree
order by (
        study_id,
        pos,
        ref,
        alt,
        gene_id,
        y_proba_full_model
    ) as
select *
from ot.l2g_log;
create database if not exists ot;
create table if not exists ot.l2g_by_gsl engine MergeTree
order by (
        gene_id,
        y_proba_full_model,
        study_id,
        pos,
        ref,
        alt
    ) as
select *
from ot.l2g_log;
-- l2g_by_gsl
ALTER TABLE l2g_by_gsl
ADD COLUMN IF NOT EXISTS variant_id String DEFAULT concat(
        cast(chrom as String),
        '_',
        cast(pos as String),
        '_',
        ref,
        '_',
        alt
    );
-- l2g_by_slg
ALTER TABLE l2g_by_slg
ADD COLUMN IF NOT EXISTS variant_id String DEFAULT concat(
        cast(chrom as String),
        '_',
        cast(pos as String),
        '_',
        ref,
        '_',
        alt
    );