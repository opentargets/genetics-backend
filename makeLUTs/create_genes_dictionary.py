#!/usr/bin/env python3

import logging
import time
import pandas as pd
from sqlalchemy import create_engine

logger = logging.getLogger()

OUTGENENAME = 'genes.json'
VALID_CHROMOSOMES = [*[str(chr) for chr in range(1, 23)], 'X', 'Y']



def build_ensembl_genes():
    '''queries the MySQL public ensembl database and outputs a gene lookup object
    in JSON format. It also injects into our sqlite database just so that we can
    do the processing directly there.
    '''

    #connect to Ensembl MySQL public server
    core = create_engine('mysql+mysqldb://anonymous@ensembldb.ensembl.org/homo_sapiens_core_75_37')

    q = """
    select
    et.exon_id,
    et.transcript_id,
    g.stable_id as gene_id,
    g.description,
    r.name as chr,
    g.seq_region_start as start,
    g.seq_region_end as end,
    e.seq_region_start as exon_start,
    e.seq_region_end as exon_end,
    t.seq_region_strand as fwdstrand
    from exon_transcript et, exon e, gene g, transcript t, seq_region r
    where
    g.canonical_transcript_id = et.transcript_id and
    g.seq_region_id = r.seq_region_id and
    r.coord_system_id = 4 and
    r.name NOT RLIKE 'CHR' and
    et.transcript_id = t.transcript_id and
    e.exon_id =et.exon_id
    """

    start_time = time.time()

    df = pd.read_sql_query(q, core,index_col='exon_id')
    df['exons'] = list(zip(df.exon_start, df.exon_end))
    df['fwdstrand'] = df['fwdstrand'].map({1:True,-1:False})
    df['tss'] = df.apply(lambda row: row['start'] if row['fwdstrand'] else row['end'], axis=1)
    keepcols = ['gene_id','description','tss','chr','start','end','fwdstrand']
    genes = pd.DataFrame(df.groupby(keepcols)['exons'].apply(list)).reset_index()
    genes.set_index('gene_id', inplace=True)
    print(genes['chr'].value_counts())
    genes.to_json(OUTGENENAME,orient='index')

    print("--- Genes table completed in %s seconds ---" % (time.time() - start_time))


def main():
    build_ensembl_genes()

if __name__ == '__main__':
    main()