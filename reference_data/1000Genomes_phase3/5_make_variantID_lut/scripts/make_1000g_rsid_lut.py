#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#

import sys
import os
import argparse
import gzip
import pandas as pd
import numpy as np

def main():

    # Parse args
    args = parse_args()

    #
    # Load datsets ------------------------------------------------------------
    #

    # Load bims
    bim_dfs = []
    for c, bim in enumerate(args.bims):
        print('Loading bim {0} of {1}...'.format(c + 1, len(args.bims)))
        df = pd.read_csv(bim, sep='\t', header=None)
        df.columns = ['chrom_1kg', 'rsid_1kg', 'None', 'pos_1kg', 'A1_1kg', 'A2_1kg']
        bim_dfs.append(df)
    bim_df = pd.concat(bim_dfs)
    bim_df = bim_df.drop_duplicates()
    print('{0} 1000G variants'.format(bim_df.shape[0]))

    # Load vcf
    print('Loading VCF...')
    vcf = pd.read_csv(args.vcf,
                      sep='\t',
                      header=None,
                      comment='#',
                      usecols=[0, 1, 2, 3, 4],
                      nrows=None)
    vcf.columns = ['chrom_ens', 'pos_ens', 'rsid_ens', 'A1_ens', 'A2_ens']

    # Explode multiallelic lines
    vcf['A2_ens'] = vcf['A2_ens'].str.split(',')
    vcf = explode(vcf, ['A2_ens'])

    #
    # Merge --------------------------------------------------------------------
    #

    # Make 1000G variant merge key
    print('Making 1000G merge key...')
    bim_df['key_1kg'] = ['_'.join( [str(l[0]), str(l[1])] + sorted([str(l[2]), str(l[3])]) ) for l in bim_df.loc[:, ['chrom_1kg', 'pos_1kg', 'A1_1kg', 'A2_1kg']].values.tolist()]

    # Make 1000G variant ID
    print('Making 1000G variant ID...')
    bim_df['varid_1kg'] = ['_'.join( [str(l[0]), str(l[1]), str(l[2]), str(l[3])] ) for l in bim_df.loc[:, ['chrom_1kg', 'pos_1kg', 'A1_1kg', 'A2_1kg']].values.tolist()]

    # Make Ensembl variant merge key
    print('Making Esembl merge key...')
    vcf['key_ens'] = ['_'.join( [str(l[0]), str(l[1])] + sorted([str(l[2]), str(l[3])]) ) for l in vcf.loc[:, ['chrom_ens', 'pos_ens', 'A1_ens', 'A2_ens']].values.tolist()]

    # Make Ensembl variant ID
    print('Making Esembl variant ID...')
    vcf['varid_ens'] = ['_'.join( [str(l[0]), str(l[1]), str(l[2]), str(l[3])] ) for l in vcf.loc[:, ['chrom_ens', 'pos_ens', 'A1_ens', 'A2_ens']].values.tolist()]

    # Merge
    print('Merging...')
    merged = pd.merge(bim_df, vcf, left_on='key_1kg', right_on='key_ens', how='left')

    # Write
    print('Writing output...')
    merged.loc[:, ['rsid_1kg', 'varid_1kg', 'rsid_ens', 'varid_ens']].to_csv(
        args.outf, sep='\t', index=None, compression='gzip')

def explode(df, columns):
    ''' Explodes multiple columns
    '''
    idx = np.repeat(df.index, df[columns[0]].str.len())
    a = df.T.reindex(columns).values
    concat = np.concatenate([np.concatenate(a[i]) for i in range(a.shape[0])])
    p = pd.DataFrame(concat.reshape(a.shape[0], -1).T, idx, columns)
    return pd.concat([df.drop(columns, axis=1), p], axis=1).reset_index(drop=True)

def parse_args():
    """ Load command line args """
    parser = argparse.ArgumentParser()
    parser.add_argument('--bims', metavar="<file>", type=str, nargs='+', required=True)
    parser.add_argument('--vcf', metavar="<file>", type=str, required=True)
    parser.add_argument('--outf', metavar="<str>", type=str, required=True)
    args = parser.parse_args()
    return args

if __name__ == '__main__':

    main()
