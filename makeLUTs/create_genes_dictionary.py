#!/usr/bin/env python3

import json
import logging
import time
import pandas as pd
from sqlalchemy import create_engine
import os
import argparse

logger = logging.getLogger()

OUTGENENAME = 'output/gene_dictionary.json'
VALID_CHROMOSOMES = [*[str(chr) for chr in range(1, 23)], 'X', 'Y', 'MT']

if not os.path.exists(os.path.dirname(OUTGENENAME)):
    os.mkdir(os.path.dirname(OUTGENENAME))


def build_ensembl_genes(pipeline_file_name, ensembl_database):
    """Queries the MySQL public ensembl database and outputs a gene lookup object in JSON format.
    Optionally write an additional file suitable for loading Ensembl gene data into the Open Targets pipeline.
    """

    # connect to Ensembl MySQL public server; port used will depend on Ensembl assembly version
    database_url = build_database_url(ensembl_database)
    print('Connecting to {}'.format(database_url))

    core = create_engine(database_url, connect_args={'compress': True})

    # SQL to retrieve required fields
    # Note that the single % in the LIKE clause have to be escaped as %%
    q = """
    SELECT
    et.exon_id,
    et.transcript_id,
    g.stable_id AS gene_id,
    x.display_label AS gene_name,
    g.description,
    g.biotype,
    g.source,
    g.version,
    a.logic_name,
    r.name AS chr,
    g.seq_region_start AS start,
    g.seq_region_end AS end,
    e.seq_region_start AS exon_start,
    e.seq_region_end AS exon_end,
    t.seq_region_strand AS fwdstrand,
    g.seq_region_strand AS strand
    FROM exon_transcript et, exon e, gene g, transcript t, seq_region r, xref AS x, coord_system AS cs, analysis a
    WHERE
    g.canonical_transcript_id = et.transcript_id AND
    g.seq_region_id = r.seq_region_id AND
    x.xref_id = g.display_xref_id AND
    r.coord_system_id = cs.coord_system_id AND
    cs.name = 'chromosome' AND cs.attrib LIKE '%%default_version%%' AND
    g.analysis_id = a.analysis_id AND
    et.transcript_id = t.transcript_id AND
    e.exon_id = et.exon_id
    """

    start_time = time.time()
    df = pd.read_sql_query(q, core, index_col='exon_id')

    # Only keep valid chromosomes
    df = df.loc[df.chr.isin(VALID_CHROMOSOMES), :]

    if (pipeline_file_name):

        # Create a new data frame with only unique gene_ids, and remove columns we don't need in the output
        df_pipeline = df.drop_duplicates(subset='gene_id')  # only store one of each gene
        df_pipeline = df_pipeline.drop(columns=['exon_start', 'exon_end', 'fwdstrand', 'transcript_id'])

        # Rename certain columns to those required by the pipeline
        df_pipeline = df_pipeline.rename(index=str, columns={"gene_id": "id", "chr": "seq_region_name", "gene_name": "display_name"})

        # Add columns derived from the meta table
        df_pipeline['assembly_name'] = get_meta(core, 'assembly.default')
        df_pipeline['db_type'] = get_meta(core, 'schema_type')
        df_pipeline['ensembl_release'] = get_meta(core, 'schema_version')
        df_pipeline['species'] = get_meta(core, 'species.production_name')

        # Add static columns, required by the pipeline
        df_pipeline['object_type'] = 'Gene'
        # all on valid chromosomes so this will always be true
        df_pipeline['is_reference'] = True

        compress = 'gzip' if pipeline_file_name.endswith('.gz') else None

        df_pipeline.to_json(pipeline_file_name, orient='records', compression=compress)
        print("Wrote Ensembl gene data to {}".format(pipeline_file_name))

    # Get TSS determined by strand
    df['fwdstrand'] = df['fwdstrand'].map({1: True, -1: False})
    df['tss'] = df.apply(lambda row: row['start']
                         if row['fwdstrand'] else row['end'], axis=1)

    # Flatten exon list
    df['exons'] = list(zip(df.exon_start, df.exon_end))
    exons_df = df.groupby('gene_id')['exons'].apply(
        flatten_exons).reset_index()

    # Merge exons to genes
    keepcols = ['gene_id', 'gene_name', 'description', 'biotype', 'chr', 'tss', 'start', 'end', 'fwdstrand']
    genes = pd.merge(df.loc[:, keepcols].drop_duplicates(), exons_df, on='gene_id', how='inner')

    # For clickhouse bools need to converted (0, 1)
    genes.fwdstrand = genes.fwdstrand.replace({False: 0, True: 1})

    # Print chromosome counts
    print(genes['chr'].value_counts())

    # Test
    print('Number of genes: {}'.format(genes.gene_id.unique().size))
    for gene in ['ENSG00000169972', 'ENSG00000217801', 'ENSG00000272141']:
        print('{} is in dataset: {}'.format(
            gene, gene in genes.gene_id.values))

    # Save json
    genes = genes.sort_values(['chr', 'start', 'end'])
    genes = genes.fillna(value='')
    genes.to_json(OUTGENENAME, orient='records', lines=True)

    print("--- Genes table completed in %s seconds ---" %
          (time.time() - start_time))


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
    return json.dumps([int(x) for x in flattened_list], separators=(',', ':'))


# Retrieve specific values from the Ensembl meta table
def get_meta(connection, field):
    result = connection.execute("SELECT meta_value FROM meta WHERE meta_key='{}'".format(field))
    records = result.fetchall()
    return records[0][0]


def main():

    parser = argparse.ArgumentParser(
        description='Genetics Portal backend data processing')

    parser.add_argument("--pipeline", metavar='FILE', action='store',
                        help="Dump gene information needed for the Open Targets pipeline to the specified file. If the filename ends in .gz, it will be automatically compressed")

    parser.add_argument("--ensembl-database", action='store',
                        help="Use the specified Ensembl database, default is homo_sapiens_core_93_37")

    args = parser.parse_args()

    build_ensembl_genes(args.pipeline, args.ensembl_database)


def build_database_url(ensembl_database):
    """ Build the correct URL based on the database required
    GRCh37 databases are on port 3337, all other databases are on port 3306
    """

    if not ensembl_database:
        ensembl_database = 'homo_sapiens_core_93_37'

    port = 3337 if str(ensembl_database).endswith('37') else 3306

    return 'mysql+mysqldb://anonymous@ensembldb.ensembl.org:{}/{}'.format(port, ensembl_database)


if __name__ == '__main__':
    main()
