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

def main():

    # Args
    in_sample = 'example_data/ukb33896_imp_chr1_v3_s487320.sample'
    in_exclusions = 'output/exclusion_list.tsv'
    out_sample = 'output/ukb_10k_downsampled.sample'
    out_sample_list = 'output/ukb_10k_downsampled.sample_list.tsv'
    n_downsample = 10000
    seed = 123

    # Load exclusions set
    with open(in_exclusions, 'r') as in_h:
        excl = set([line.rstrip() for line in in_h])
    
    # Load sample file
    df = pd.read_csv(
        in_sample,
        header=[0, 1], 
        sep=' ',
        dtype={'ID_1': 'str', 'ID_2': 'str'}
    )

    # Add a column showing of whether is exclusion
    df[('is_exclusion', 'D')] = (
        df['ID_1']
        .isin(excl)
        .replace({False: 0, True: 1})
    )

    # Add a column showing whether sample is retracted consent
    df[('is_retracted', 'D')] = (
        df[('ID_1', '0')]
        .apply(lambda x: int(x) <= 0)
        .replace({False: 0, True: 1})
    )

    # Down-sample samples not excluded
    chosen_samples = set(
        df
        .loc[((df[('is_exclusion', 'D')] == 0) & (df[('is_retracted', 'D')] == 0)), ('ID_1', '0')]
        .sample(n=n_downsample, random_state=seed)
        .tolist()
    )
    df[('is_selected', 'D')] = (
        df['ID_1']
        .isin(chosen_samples)
        .replace({False: 0, True: 1})
    )

    # Write new sample file
    df.to_csv(
        out_sample,
        sep=' ',
        index=None
    )

    # Write list of samples to a file
    with open(out_sample_list, 'w') as out_h:
        for sample in sorted(chosen_samples):
            out_h.write(sample + '\n')

    return 0

if __name__ == '__main__':

    main()
