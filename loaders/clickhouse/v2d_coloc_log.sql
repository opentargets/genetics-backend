create database if not exists ot;
create table if not exists ot.v2d_coloc_log(
    coloc_h0 Float64,
    coloc_h1 Float64,
    coloc_h2 Float64,
    coloc_h3 Float64,
    coloc_h4 Float64,
    left_chrom String,
    left_pos UInt32,
    left_ref String,
    left_alt String,
    left_study String,
    left_type String,
    coloc_n_vars UInt32,
    right_chrom String,
    right_pos UInt32,
    right_ref String,
    right_alt String,
    right_study String,
    right_type String,
    coloc_h4_h3 Float64,
    coloc_log2_h4_h3 Float64,
    is_flipped UInt8,
    right_gene_id String,
    right_bio_feature String,
    right_phenotype String)
engine = Log;

