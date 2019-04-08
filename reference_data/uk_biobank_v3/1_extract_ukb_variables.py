#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#
"""
bsub -q small -J interactive -n 1 -R "select[mem>8000] rusage[mem=8000] span[hosts=1]" -M8000 -Is bash
"""

import gzip
import sys

def main():

    # Args
    in_ukb = '/nfs/users/nfs_e/em21/otcoregen/uk_biobank_data/data/phenotypes/tsv/ukb27852.tsv.gz'
    outf = 'temp_ukb27852.extraction.tsv'
    sep = '\t'
    field_prefixes = [
        'f.eid',
        'f.31.',    # Reported sex
        'f.22001.', # Genetic sex
        'f.22006.', # White bristish
        'f.22019.', # Sex chromosome aneuploidy. Karyotypes not XX or XY
        'f.22027.', # Heterozygosity or missingness rate outliers
    ]

    # Get list of column indices where header starts with `field_prefixes`
    col_indices = []
    with gzip.open(in_ukb, 'r') as in_h:
        header = in_h.readline().decode().rstrip().split(sep)
        for i, col in enumerate(header):
            for field_prefix in field_prefixes:
                if col.startswith(field_prefix):
                    col_indices.append(i)
                    break
    
    # Compare field_prefixes to extracted column header and raise error if any
    # were not found
    header_extracted = [header[i] for i in col_indices]
    for field_prefix in field_prefixes:
        if not any([col.startswith(field_prefix) for col in header_extracted]):
            sys.exit('ERROR: Field prefix "{}" was not found'.format(field_prefix))

    # Extract `col_indices` and write to new file
    with gzip.open(in_ukb, 'r') as in_h:
        with open(outf, 'w') as out_h:
            for line in in_h:
                parts = line.decode().rstrip().split(sep)
                out_row = [parts[i] for i in col_indices]
                out_h.write(sep.join(out_row) + '\n')

    return 0

if __name__ == '__main__':

    main()
