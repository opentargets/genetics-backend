#!/bin/bash

data_release="190505"
# create dataset tables needed
bq --project=open-targets-genetics mk -d --location=EU "${data_release}"
bq --project=open-targets-genetics mk -t --location=EU --description "Variant index" $data_release.variants
bq --project=open-targets-genetics mk -t --location=EU --description "Study index" $data_release.studies
bq --project=open-targets-genetics mk -t --location=EU --description "Study Overlap index" $data_release.studies_overlap
bq --project=open-targets-genetics mk -t --location=EU --description "Gene index" $data_release.genes
bq --project=open-targets-genetics mk -t --location=EU --description "Variant to gene index" $data_release.variant_gene
bq --project=open-targets-genetics mk -t --location=EU --description "Variant to study-trait index" $data_release.variant_disease
bq --project=open-targets-genetics mk -t --location=EU --description "Gene to variant to study-trait index" $data_release.disease_variant_gene
bq --project=open-targets-genetics mk -t --location=EU --description "Summary stats GWAS pval 0.05 cut-off" $data_release.sa_gwas
bq --project=open-targets-genetics mk -t --location=EU --description "Summary stats Molecular Trait pval 0.05 cut-off" $data_release.sa_molecular_trait
bq --project=open-targets-genetics mk -t --location=EU --description "Variant to study-trait index colocalisation analysis" $data_release.variant_disease_coloc
bq --project=open-targets-genetics mk -t --location=EU --description "Variant to study-trait index credible set" $data_release.variant_disease_credset

# load data into tables
bq --project=open-targets-genetics load --source_format=PARQUET \
  $data_release.variants \
  gs://genetics-portal-output/$data_release/variant-index/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.genes.schema.json \
  $data_release.genes \
  gs://genetics-portal-output/$data_release/lut/genes-index/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.studies.schema.json \
  $data_release.studies \
  gs://genetics-portal-output/$data_release/lut/study-index/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.studies_overlap.schema.json \
  $data_release.studies_overlap \
  gs://genetics-portal-output/$data_release/lut/overlap-index/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.v2g.schema.json \
  $data_release.variant_gene \
  gs://genetics-portal-output/$data_release/v2g/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.v2d.schema.json \
  $data_release.variant_disease \
  gs://genetics-portal-output/$data_release/v2d/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.d2v2g.schema.json \
  $data_release.disease_variant_gene \
  gs://genetics-portal-output/$data_release/d2v2g/part-\*

bq --project=open-targets-genetics load --source_format=PARQUET \
  $data_release.sa_gwas \
  gs://genetics-portal-output/$data_release/sa/gwas/part-\*

bq --project=open-targets-genetics load --source_format=PARQUET \
  $data_release.sa_molecular_trait \
  gs://genetics-portal-output/$data_release/sa/molecular_trait/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.v2d_coloc.schema.json \
  $data_release.variant_disease_coloc \
  gs://genetics-portal-output/$data_release/v2d_coloc/part-\*

bq --project=open-targets-genetics load --source_format=NEWLINE_DELIMITED_JSON \
  --schema=bq.v2d_credset.schema.json \
  $data_release.variant_disease_credset \
  gs://genetics-portal-output/$data_release/v2d_credset/part-\*

# get schema from parquet ones as we need in json format
# bq show --format=prettyjson open-targets-genetics:$data_release.variants | jq '.schema.fields' > bq.variants.schema.json
# bq show --format=prettyjson open-targets-genetics:190505.sa_gwas | jq '.schema.fields' > bq.sa_gwas.schema.json
# bq show --format=prettyjson open-targets-genetics:190505.sa_molecular_trait | jq '.schema.fields' > bq.sa_molecular_trait.schema.json

