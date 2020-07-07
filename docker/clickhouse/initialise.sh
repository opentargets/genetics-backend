#!/bin/bash
set -x
# See if the VM has already been configured
OT_RCFILE=/etc/opentargets.rc

if [ -f "$OT_RCFILE" ]; then
    echo "$OT_RCFILE exist so machine is already configured"
    exit 0
fi

## Helper functions

load_foreach_json() {
  # you need two parameters, the path_prefix to make the wildcard and
  # the table_name name to load into
  local path_prefix=$1
  local table_name=$2
  echo loading $path_prefix glob files into this table $table_name
  gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/part-*)
  for file in $gs_files; do
    echo $file
    "${SCRIPT_DIR}/run.sh" cat "${file}" |
      clickhouse-client --query="insert into ${table_name} format JSONEachRow "
  done
  echo "done loading $path_prefix glob files into this table $table_name"
}

load_foreach_json_gz() {
  # you need two parameters, the path_prefix to make the wildcard and
  # the table_name name to load into
  # this function is a temporal fix for a jsonlines dataset where files
  # come compressed
  local path_prefix=$1
  local table_name=$2
  echo loading $path_prefix glob files into this table $table_name
  gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/part-*)
  for file in $gs_files; do
    echo $file
    "${SCRIPT_DIR}/run.sh" cat "${file}" | gunzip |
      clickhouse-client \
        --query="insert into ${table_name} format JSONEachRow "
  done
  echo "done loading $path_prefix glob files into this table $table_name"
}

load_foreach_parquet() {
  # you need two parameters, the path_prefix to make the wildcard and
  # the table_name name to load into
  local path_prefix=$1
  local table_name=$2
  echo loading $path_prefix glob files into this table $table_name
  gs_files=$("${SCRIPT_DIR}/run.sh" ls "${path_prefix}"/*.parquet)
  for file in $gs_files; do
    echo $file
    "${SCRIPT_DIR}/run.sh" cat "${file}" |
      clickhouse-client \
        --query="insert into ${table_name} format Parquet "
  done
  echo "done loading $path_prefix glob files into this table $table_name"
}

## Get data from gcloud
echo "do not forget to create the tables and load the data in"


## Database setup
# drop all dbs
echo "Initialising database..."
clickhouse-client -h "localhost" --query="drop database if exists ot;"

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
clickhouse-client -m -n <"${SCRIPT_DIR}/studies_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/studies_overlap_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/variants_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/d2v2g_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2g_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_coloc_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_credibleset_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_sa_gwas_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_sa_molecular_traits_log.sql"
clickhouse-client -m -n <"${SCRIPT_DIR}/l2g_log.sql"


## Load data
load_foreach_json "${DATA_VERSION}/lut/study-index" "ot.studies_log"
load_foreach_json "${base_path}/lut/overlap-index" "ot.studies_overlap_log"
load_foreach_json "${base_path}/lut/variant-index" "ot.variants_log"
load_foreach_json "${base_path}/d2v2g" "ot.d2v2g_log"
load_foreach_json "${base_path}/v2d" "ot.v2d_log"
load_foreach_json "${base_path}/v2g" "ot.v2g_log"
load_foreach_json "${base_path}/v2d_coloc" "ot.v2d_coloc_log"
load_foreach_json_gz "${base_path}/v2d_credset" "ot.v2d_credset_log"
load_foreach_parquet "${base_path}/sa/gwas" "ot.v2d_sa_gwas_log"
load_foreach_parquet "${base_path}/sa/molecular_trait" "ot.v2d_sa_molecular_trait_log"
load_foreach_parquet "${base_path}/l2g" "ot.l2g_log"

## Create final tables
echo "create genes table"
clickhouse-client -h "localhost" -m -n <"${SCRIPT_DIR}/genes.sql"

echo "create studies tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/studies.sql"

echo "create studies overlap tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/studies_overlap.sql"

echo "create dictionaries tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/dictionaries.sql"

echo "create variants tables"
clickhouse-client  -m -n <"${SCRIPT_DIR}/variants.sql"

echo "create d2v2g tables"
clickhouse-client  -m -n <"${SCRIPT_DIR}/d2v2g.sql"

echo "create v2d tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d.sql"

echo "create v2g tables"
clickhouse-client   -m -n <"${SCRIPT_DIR}/v2g.sql"

echo "create v2g structure"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2g_structure.sql"

echo "compute d2v2g_scored table"
clickhouse-client -m -n <"${SCRIPT_DIR}/d2v2g_scored.sql"

echo "load coloc data"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_coloc.sql"

echo "load credible set"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_credibleset.sql"

echo "generate sumstats gwas tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_sa_gwas.sql"

echo "generate sumstats molecular trait tables"
clickhouse-client -m -n <"${SCRIPT_DIR}/v2d_sa_molecular_traits.sql"

echo "load locus 2 gene"
clickhouse-client -m -n <"${SCRIPT_DIR}/l2g.sql"

echo "building manhattan table"
clickhouse-client   -m -n <"${SCRIPT_DIR}/manhattan.sql"

## Drop intermediate tables
clickhouse-client -m -n -q "drop table ot.studies_log;"
clickhouse-client -m -n -q "drop table ot.studies_overlap_log;"
clickhouse-client -m -n -q "drop table ot.variants_log;"
clickhouse-client -m -n -q "drop table ot.d2v2g_log;"
clickhouse-client -m -n -q "drop table ot.v2d_log;"
clickhouse-client -m -n -q "drop table ot.v2g_log;"
clickhouse-client -m -n -q "drop table ot.v2d_coloc_log;"
clickhouse-client -m -n -q "drop table ot.v2d_credset_log;"
clickhouse-client -m -n -q "drop table if exists ot.v2d_sa_gwas_log;"
clickhouse-client -m -n -q "drop table if exists ot.v2d_sa_molecular_trait_log;"
clickhouse-client -m -n -q "drop table ot.l2g_log;"

## Delete unneeded data files

## Log create date
echo touching $OT_RCFILE
cat <<EOF > $OT_RCFILE
`date`
EOF