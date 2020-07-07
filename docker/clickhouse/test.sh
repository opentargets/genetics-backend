#! /bin/bash
SCRIPT_DIR="hello"
intermediateTables=(
  studies
  studies_overlap
  variants
  d2v2g
  v2d
  v2g
  v2d_coloc
  v2d_credibleset
  v2d_sa_gwas
  v2d_sa_molecular_traits
  l2g
)
## Create intermediary tables
for t in "${intermediateTables[@]}"; do 
  echo "${SCRIPT_DIR}/${t}_log.sql"; 
done