#!/usr/bin/env python3

import json
import logging
import time
import pandas as pd
from sqlalchemy import create_engine
import os

logger = logging.getLogger()

OUTGENENAME = 'output/gene_dictionary.json'
VALID_CHROMOSOMES = [*[str(chr) for chr in range(1, 23)], 'X', 'Y', 'MT']

if not os.path.exists(os.path.dirname(OUTGENENAME)):
    os.mkdir(os.path.dirname(OUTGENENAME))

def build_ensembl_genes():
    '''queries the MySQL public ensembl database and outputs a gene lookup object
    in JSON format. It also injects into our sqlite database just so that we can
    do the processing directly there.
    '''

    #connect to Ensembl MySQL public server
    core = create_engine('mysql+mysqldb://anonymous@ensembldb.ensembl.org:3337/homo_sapiens_core_93_37')

    q = """
    select
    et.exon_id,
    et.transcript_id,
    g.stable_id as gene_id,
    x.display_label as gene_name,
    g.description,
    g.biotype,
    r.name as chr,
    g.seq_region_start as start,
    g.seq_region_end as end,
    e.seq_region_start as exon_start,
    e.seq_region_end as exon_end,
    t.seq_region_strand as fwdstrand
    from exon_transcript et, exon e, gene g, transcript t, seq_region r, xref as x
    where
    g.canonical_transcript_id = et.transcript_id and
    g.seq_region_id = r.seq_region_id and
    x.xref_id = g.display_xref_id and
    r.coord_system_id = 2 and
    r.name NOT RLIKE 'CHR' and
    et.transcript_id = t.transcript_id and
    e.exon_id = et.exon_id
    """

    start_time = time.time()
    df = pd.read_sql_query(q, core, index_col='exon_id')

    # Only keep valid chromosomes
    df = df.loc[df.chr.isin(VALID_CHROMOSOMES), :]

    # Get TSS determined by strand
    df['fwdstrand'] = df['fwdstrand'].map({1:True,-1:False})
    df['tss'] = df.apply(lambda row: row['start'] if row['fwdstrand'] else row['end'], axis=1)

    # Flatten exon list
    df['exons'] = list(zip(df.exon_start, df.exon_end))
    exons_df = df.groupby('gene_id')['exons'].apply(flatten_exons).reset_index()

    # Merge exons to genes
    keepcols = ['gene_id', 'gene_name', 'description', 'biotype', 'chr', 'tss',
                'start', 'end', 'fwdstrand']
    genes = pd.merge(df.loc[:, keepcols].drop_duplicates(), exons_df,
                     on='gene_id', how='inner')

    # For clickhouse bools need to converted (0, 1)
    genes.fwdstrand = genes.fwdstrand.replace({False: 0, True: 1})

    # Print chromosome counts
    print(genes['chr'].value_counts())

    # Test
    print('Number of genes: {}'.format(genes.gene_id.unique().size))
    for gene in ['ENSG00000169972', 'ENSG00000217801', 'ENSG00000272141']:
        print('{} is in dataset: {}'.format(gene, gene in genes.gene_id.values))

    # Save json
    genes = genes.sort_values(['chr', 'start', 'end'])
    genes = genes.fillna(value='')
    genes.to_json(OUTGENENAME, orient='records', lines=True)

    print("--- Genes table completed in %s seconds ---" % (time.time() - start_time))

def flatten_exons(srs):
    ''' Flattens pd.Series list of lists into a single list.
    Clickhouse requires the list to be represented as a string with no spaces.

    Args:
        srs (pd.Series): Series containing list of lists
    Returns:
        (str): string representation of flatttened list
    '''
    flattened_list = [item for sublist in srs.tolist() for item in sublist]
    assert(len(flattened_list) % 2 == 0)
    # return str(flattened_list).replace(' ', '')
    return json.dumps([int(x) for x in flattened_list], separators=(',',':'))

def main():
    build_ensembl_genes()

if __name__ == '__main__':
    main()
