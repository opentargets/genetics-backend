
#!/usr/bin/env bash

GENETIC_OUT_BUCKET=genetics-portal-output

usage() {
    echo "Usage: $0 <nameoftable> \n Choose one of:
    \n v2g \n v2d \n d2v2g \n variant-index" 1>&2; exit 1; }

if [ -z "$1" ]; then
    usage
fi


### transform queries
### ---------------- v2g ----------------------------

read -r -d '' V2DQUERY <<EOF
SELECT
JSON_EXTRACT_SCALAR(item, '$.chr_id') chr_id,
CAST(JSON_EXTRACT_SCALAR(item, '$.position') as INT64) position,
JSON_EXTRACT_SCALAR(item, '$.ref_allele') ref_allele,
JSON_EXTRACT_SCALAR(item, '$.alt_allele') alt_allele,
JSON_EXTRACT_SCALAR(item, '$.stid') stid,
JSON_EXTRACT_SCALAR(item, '$.index_variant_id') index_variant_id,
CAST(JSON_EXTRACT_SCALAR(item, '$.r2') AS FLOAT64) r2,
CAST(JSON_EXTRACT_SCALAR(item, '$.afr_1000g_prop') AS FLOAT64) afr_1000g_prop,
CAST(JSON_EXTRACT_SCALAR(item, '$.amr_1000g_prop') AS FLOAT64) amr_1000g_prop,
CAST(JSON_EXTRACT_SCALAR(item, '$.eas_1000g_prop') AS FLOAT64) eas_1000g_prop,
CAST(JSON_EXTRACT_SCALAR(item, '$.eur_1000g_prop') AS FLOAT64) eur_1000g_prop,
CAST(JSON_EXTRACT_SCALAR(item, '$.sas_1000g_prop') AS FLOAT64) sas_1000g_prop,
CAST(JSON_EXTRACT_SCALAR(item, '$.log10_abf') AS FLOAT64) log10_abf,
CAST(JSON_EXTRACT_SCALAR(item, '$.posterior_prob') AS FLOAT64) posterior_prob,
JSON_EXTRACT_SCALAR(item, '$.pmid') pmid,
JSON_EXTRACT_SCALAR(item, '$.pub_date') pub_date,
JSON_EXTRACT_SCALAR(item, '$.pub_journal') pub_journal,
JSON_EXTRACT_SCALAR(item, '$.pub_title') pub_title,
JSON_EXTRACT_SCALAR(item, '$.pub_author') pub_author,
JSON_EXTRACT_SCALAR(item, '$.trait_reported') trait_reported,
JSON_EXTRACT_SCALAR(item, '$.trait_efos') trait_efos,
JSON_EXTRACT_SCALAR(item, '$.trait_code') trait_code,
JSON_EXTRACT_SCALAR(item, '$.ancestry_initial') ancestry_initial,
JSON_EXTRACT_SCALAR(item, '$.ancestry_replication') ancestry_replication,
CAST(JSON_EXTRACT_SCALAR(item, '$.n_initial') AS INT64) n_initial,
CAST(JSON_EXTRACT_SCALAR(item, '$.n_replication') AS INT64) n_replication,
CAST(JSON_EXTRACT_SCALAR(item, '$.n_cases') AS INT64) n_cases,
CAST(JSON_EXTRACT_SCALAR(item, '$.pval') AS FLOAT64) pval,
JSON_EXTRACT_SCALAR(item, '$.index_variant_rsid') index_variant_rsid,
JSON_EXTRACT_SCALAR(item, '$.index_chr_id') index_chr_id,
CAST(JSON_EXTRACT_SCALAR(item, '$.index_position') AS INT64) index_position,
JSON_EXTRACT_SCALAR(item, '$.index_ref_allele') index_ref_allele,
JSON_EXTRACT_SCALAR(item, '$.index_alt_allele') index_alt_allele,
JSON_EXTRACT_SCALAR(item, '$.variant_id') variant_id,
JSON_EXTRACT_SCALAR(item, '$.rs_id') rs_id

FROM v2d.$(date +%Y%m%d)_raw
EOF

#### ----------------- d2v2g -----------------------------

read -r -d '' D2V2GQUERY <<EOF
SELECT
  JSON_EXTRACT_SCALAR(item, '$.chr_id') chr_id,
  CAST(JSON_EXTRACT_SCALAR(item, '$.position') as INT64) position,
  JSON_EXTRACT_SCALAR(item, '$.ref_allele') ref_allele,
  JSON_EXTRACT_SCALAR(item, '$.alt_allele') alt_allele,
  JSON_EXTRACT_SCALAR(item, '$.stid') stid,
  JSON_EXTRACT_SCALAR(item, '$.index_variant_id') index_variant_id,
  CAST(JSON_EXTRACT_SCALAR(item, '$.r2') as FLOAT64) r2,
  CAST(JSON_EXTRACT_SCALAR(item, '$.afr_1000g_prop') as FLOAT64) afr_1000g_prop,
  CAST(JSON_EXTRACT_SCALAR(item, '$.amr_1000g_prop') as FLOAT64) amr_1000g_prop,
  CAST(JSON_EXTRACT_SCALAR(item, '$.eas_1000g_prop') as FLOAT64) eas_1000g_prop,
  CAST(JSON_EXTRACT_SCALAR(item, '$.eur_1000g_prop') as FLOAT64) eur_1000g_prop,
  CAST(JSON_EXTRACT_SCALAR(item, '$.sas_1000g_prop') as FLOAT64) sas_1000g_prop,
  CAST(JSON_EXTRACT_SCALAR(item, '$.log10_abf') as FLOAT64) log10_abf,
  CAST(JSON_EXTRACT_SCALAR(item, '$.posterior_prob') as FLOAT64) posterior_prob,
  JSON_EXTRACT_SCALAR(item, '$.pmid') pmid,
  JSON_EXTRACT_SCALAR(item, '$.pub_date') pub_date,
  JSON_EXTRACT_SCALAR(item, '$.pub_journal') pub_journal,
  JSON_EXTRACT_SCALAR(item, '$.pub_title') pub_title,
  JSON_EXTRACT_SCALAR(item, '$.pub_author') pub_author,
  JSON_EXTRACT_SCALAR(item, '$.trait_reported') trait_reported,
  JSON_EXTRACT_SCALAR(item, '$.trait_efos') trait_efos,
  JSON_EXTRACT_SCALAR(item, '$.trait_code') trait_code,
  JSON_EXTRACT_SCALAR(item, '$.ancestry_initial') ancestry_initial,
  JSON_EXTRACT_SCALAR(item, '$.ancestry_replication') ancestry_replication,
  CAST(JSON_EXTRACT_SCALAR(item, '$.n_initial') as INT64) n_initial,
  CAST(JSON_EXTRACT_SCALAR(item, '$.n_replication') as INT64) n_replication,
  CAST(JSON_EXTRACT_SCALAR(item, '$.n_cases') as INT64) n_cases,
  CAST(JSON_EXTRACT_SCALAR(item, '$.pval') as FLOAT64) pval,
  JSON_EXTRACT_SCALAR(item, '$.index_variant_rsid') index_variant_rsid,
  JSON_EXTRACT_SCALAR(item, '$.index_chr_id') index_chr_id,
  CAST(JSON_EXTRACT_SCALAR(item, '$.index_position') AS INT64) index_position,
  JSON_EXTRACT_SCALAR(item, '$.index_ref_allele') index_ref_allele,
  JSON_EXTRACT_SCALAR(item, '$.index_alt_allele') index_alt_allele,
  JSON_EXTRACT_SCALAR(item, '$.variant_id') variant_id,
  JSON_EXTRACT_SCALAR(item, '$.rs_id') rs_id,
  JSON_EXTRACT_SCALAR(item, '$.gene_chr') gene_chr,
  JSON_EXTRACT_SCALAR(item, '$.gene_id') gene_id,
  CAST(JSON_EXTRACT_SCALAR(item, '$.gene_start') as INT64) gene_start,
  CAST(JSON_EXTRACT_SCALAR(item, '$.gene_end') as INT64) gene_end,
  JSON_EXTRACT_SCALAR(item, '$.gene_type') gene_type,
  JSON_EXTRACT_SCALAR(item, '$.gene_name') gene_name,
  JSON_EXTRACT_SCALAR(item, '$.feature') feature,
  JSON_EXTRACT_SCALAR(item, '$.type_id') type_id,
  JSON_EXTRACT_SCALAR(item, '$.source_id') source_id,
  JSON_EXTRACT_SCALAR(item, '$.fpred_labels') fpred_labels,
  CAST(JSON_EXTRACT_SCALAR(item, '$.fpred_scores') as FLOAT64) fpred_scores,
  JSON_EXTRACT_SCALAR(item, '$.fpred_max_label') fpred_max_label,
  CAST(JSON_EXTRACT_SCALAR(item, '$.fpred_max_score') as FLOAT64) fpred_max_score,
  CAST(JSON_EXTRACT_SCALAR(item, '$.qtl_beta') as FLOAT64) qtl_beta,
  CAST(JSON_EXTRACT_SCALAR(item, '$.qtl_se') as FLOAT64) qtl_se,
  CAST(JSON_EXTRACT_SCALAR(item, '$.qtl_pval') as FLOAT64) qtl_pval,
  CAST(JSON_EXTRACT_SCALAR(item, '$.qtl_score') as FLOAT64) qtl_score,
  CAST(JSON_EXTRACT_SCALAR(item, '$.interval_score') as FLOAT64) interval_score,
  CAST(JSON_EXTRACT_SCALAR(item, '$.qtl_score_q') as FLOAT64) qtl_score_q,
  CAST(JSON_EXTRACT_SCALAR(item, '$.interval_score_q') as FLOAT64) interval_score_q
FROM d2v2g.$(date +%Y%m%d)_raw
EOF



case "$1" in
    v2g)
        bq --location=EU load --source_format=NEWLINE_DELIMITED_JSON v2g.$(date +%Y%m%d) "gs://${GENETIC_OUT_BUCKET}/v2g/*.json" ./bq.v2g.schema.json
        ;;
    v2d)
        echo --first job: import raw JSON strings
        bq --location=EU load --source_format=CSV -F "tab"  v2d.$(date +%Y%m%d)_raw "gs://${GENETIC_OUT_BUCKET}/v2d/*.json" item

        echo --second job: create table from query
        bq --location=EU query --destination_table v2d.$(date +%Y%m%d) --use_legacy_sql=false $V2DQUERY
        ;;
    d2v2g)
        echo --first job: import raw JSON strings
        bq --location=EU load --source_format=CSV -F "tab" d2v2g.$(date +%Y%m%d)_raw "gs://${GENETIC_OUT_BUCKET}/d2v2g/*.json" item
        ;;
    d2v2gtransform)
        echo --second job: create table from query
        bq --location=EU query --destination_table d2v2g.$(date +%Y%m%d) --use_legacy_sql=false $D2V2GQUERY
        ;;
    variant-index)
        bq --location=EU load --source_format=PARQUET variant_idx.$(date +%Y%m%d) "gs://${GENETIC_OUT_BUCKET}/variant-index/*.parquet"
        ;;
    *)
        usage
        ;;
esac

