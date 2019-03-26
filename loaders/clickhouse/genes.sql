create table if not exists ot.genes (
    gene_id String,
    gene_name String,
    biotype String,
    chr String,
    tss UInt32,
    start UInt32,
    end UInt32,
    fwdstrand UInt8,
    exons Array(UInt32) default []
) engine MergeTree order by (gene_id)
