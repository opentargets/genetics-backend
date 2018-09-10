create table ot.gene (
    gene_id String,
    gene_name String,
    biotype String,
    chr String,
    tss UInt32,
    start UInt32,
    end UInt32,
    fwdstrand UInt8,
    exons String
) Engine = Dictionary(gene)

create table ot.v2gw (
    source_id String,
    weight Float64
) Engine = Dictionary(v2gw)
