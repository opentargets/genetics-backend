#!/bin/bash

echo generate gwas log and mergetree tables

gwas_files=$(gsutil ls "gs://genetics-portal-sumstats-b38/filtered/pvalue_0.05/gwas/part-*")
clickhouse-client -m -n < v2d_sa_gwas_log.sql
for file in $gwas_files; do
        echo $file
        gsutil cat "${file}" | \
         clickhouse-client -h 127.0.0.1 \
             --query="insert into ot.v2d_sa_gwas_log format JSONEachRow "
done
clickhouse-client -m -n < v2d_sa_gwas.sql

echo create genes table

moltraits_files=$(gsutil ls "gs://genetics-portal-sumstats-b38/filtered/pvalue_0.05/molecular_trait/part-*")
clickhouse-client -m -n < v2d_sa_molecular_traits_log.sql
for file in $moltraits_files; do
        echo $file
        gsutil cat "${file}" | \
         clickhouse-client -h 127.0.0.1 \
             --query="insert into ot.v2d_sa_molecular_trait_log format JSONEachRow "
done
clickhouse-client -m -n < v2d_sa_molecular_traits.sql
