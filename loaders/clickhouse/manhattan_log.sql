create database if not exists ot;
create table if not exists ot.manhattan_log(
                                           study String,
                                           chrom String,
                                           pos UInt32,
                                           ref String,
                                           alt String,
                                           pval Float64,
                                           pval_mantissa Float64,
                                           pval_exponent Int32,
                                           odds Nullable(Float64),
                                           oddsL Nullable(Float64),
                                           oddsU Nullable(Float64),
                                           direction Nullable(String),
                                           beta Nullable(Float64),
                                           betaL Nullable(Float64),
                                           betaU Nullable(Float64),
                                           credibleSetSize Nullable(UInt64),
                                           ldSetSize Nullable(UInt64),
                                           uniq_variants UInt64,
                                           top10_genes_raw_ids Array(Nullable(String)) default [],
                                           top10_genes_raw_score Array(Float64) default [],
                                           top10_genes_coloc_ids Array(Nullable(String)) default [],
                                           top10_genes_coloc_score Array(Float64) default [],
                                           top10_genes_l2g_ids Array(Nullable(String)) default [],
                                           top10_genes_l2g_score Array(Float64) default []
)
engine = Log;