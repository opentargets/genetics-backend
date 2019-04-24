#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#
"""
Make inclusion and exclusion criteria based on:

1. Reported vs. genetic sex
2. Reported white british
3. Sex chromosome aneuploidy
4. Heterozygosity or missingness rate outliers
5. Relatedness

For this project I want only highly unrelated individuals, so I will exclude
anyone in the relatedness file regardless of threshold.
"""

import sys
import os
import pandas as pd
from functools import reduce

def main():

    # Args
    in_phenos = 'example_data/temp_ukb27852.extraction.tsv'
    in_relatedness = 'example_data/ukb33896_rel_s488288.dat'
    out_inclusions = 'output/inclusions_list.tsv'
    out_exclusions = 'output/exclusion_list.tsv'

    # Load data
    pheno_df = pd.read_csv(in_phenos, sep='\t',
        dtype={'f.eid': 'str'})
    rel_df = pd.read_csv(in_relatedness, sep=' ', header=0,
        dtype={'ID1': 'str', 'ID2': 'str'})
    
    # Init dict to hold inlc/exlc pd.Series
    incl = {}
    excl = {}

    # Make reported sex vs genetic sex outliers
    incl['sex'] = (
        (pheno_df['f.31.0.0'] == pheno_df['f.22001.0.0']) &
        (~pd.isnull(pheno_df['f.31.0.0'])) &
        (~pd.isnull(pheno_df['f.22001.0.0']))
    )
    excl['sex'] = (
        (pheno_df['f.31.0.0'] != pheno_df['f.22001.0.0']) &
        (~pd.isnull(pheno_df['f.31.0.0'])) &
        (~pd.isnull(pheno_df['f.22001.0.0']))
    )

    # Make exclusions based on reported white british ancestry
    incl['white_british'] = (
        pheno_df['f.22006.0.0'] == 1
    )
    excl['white_british'] = (
        pheno_df['f.22006.0.0'] != 1
    )
    
    # Make exclusions based on aneuploidy
    incl['aneuploidy'] = (
        pheno_df['f.22019.0.0'] != 1
    )
    excl['aneuploidy'] = (
        pheno_df['f.22019.0.0'] == 1
    )

    # Make exclusions based on heterozygosity/missingness
    incl['het_missing'] = (
        pheno_df['f.22027.0.0'] != 1
    )
    excl['het_missing'] = (
        pheno_df['f.22027.0.0'] == 1
    )

    # Based on relatedness
    samples_to_exclude = set(rel_df['ID1'].tolist() + rel_df['ID2'].tolist())
    incl['relatedness'] = (
        ~pheno_df['f.eid'].isin(samples_to_exclude)
    )
    excl['relatedness'] = (
        pheno_df['f.eid'].isin(samples_to_exclude)
    )

    # Make combined inclusion list
    incl['combined'] = reduce(lambda x, y: x & y, incl.values())

    # Make combined exclusion list
    excl['combined'] = reduce(lambda x, y: x + y, excl.values())

    # Print how many exclusions are being made
    for key in incl.keys():
        print('{}: ({}, {})'.format(key, incl[key].sum(), excl[key].sum()))

    # Write list of IDs to include and exclude
    os.makedirs(os.path.dirname(out_inclusions), exist_ok=True)
    (   pheno_df.loc[incl['combined'], 'f.eid']
                .to_csv(out_inclusions,
                    sep='\t',
                    header=False,
                    index=None)
    )
    os.makedirs(os.path.dirname(out_exclusions), exist_ok=True)
    (   pheno_df.loc[excl['combined'], 'f.eid']
                .to_csv(out_exclusions,
                    sep='\t',
                    header=False,
                    index=None)
    )
    
    # # DEBUG make a dataframe of all to check visually
    # df_dict = {}
    # for key, val in incl.items():
    #     df_dict['incl_' + key] = val
    # for key, val in excl.items():
    #     df_dict['excl_' + key] = val
    # df = pd.DataFrame.from_dict(df_dict, orient='columns')
    # df.to_csv('test.tsv', sep='\t', index=None)


    return 0



if __name__ == '__main__':

    main()
