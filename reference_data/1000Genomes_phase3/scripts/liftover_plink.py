#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#

'''
export PYSPARK_SUBMIT_ARGS="--driver-memory 8g pyspark-shell"
'''

import hail as hl
import sys
import argparse
import pyspark
from pyspark.sql.functions import *
from pyspark.sql.types import *

def main():

    # Parse args
    args = parse_args()

    # Prepare liftover
    rg37 = hl.get_reference('GRCh37')
    rg38 = hl.get_reference('GRCh38')
    rg37.add_liftover(args.chainfile, rg38)

    # Create my own rg38 with altered names
    rg38_custom_contigs = [contig.replace('chr', '') for contig in rg38.contigs]
    rg38_custom_lens = {}
    for contig in rg38.lengths:
        rg38_custom_lens[contig.replace('chr', '')] = rg38.lengths[contig]
    rg38_custom = hl.ReferenceGenome(
        'rg38_custom', rg38_custom_contigs, rg38_custom_lens)

    # Load plink
    mt = hl.import_plink(
        bed=args.in_plink + '.bed',
        bim=args.in_plink + '.bim',
        fam=args.in_plink + '.fam',
        reference_genome='GRCh37'
    )

    # # Re-call to remove phasing (required for plink output)
    # mt = mt.annotate_entries(GT=hl.call(mt.GT[0], mt.GT[1], phased=False))

    # Liftover
    mt = mt.annotate_rows(
        locus_GRCh38 = hl.liftover(mt.locus, 'GRCh38')
    )

    # Strip chr from contig name (causes problems with GCTA)
    mt = mt.annotate_rows(
        contig_GRCh38=mt.locus_GRCh38.contig.replace('chr', '')
    )

    # Swap GRCh37 locus for GRCh38 (but have to use rg38_custom)
    mt = mt.key_rows_by()
    mt = mt.annotate_rows(locus=hl.locus(mt.contig_GRCh38,
                                            mt.locus_GRCh38.position,
                                            reference_genome=rg38_custom))
    mt = mt.key_rows_by(mt.locus, mt.alleles)

    # Remove rows with missing locus (after liftover)
    mt = mt.filter_rows(hl.is_defined(mt.locus))

    # Write plink format
    hl.export_plink(
        dataset=mt,
        output=args.out_plink
    )

    return 0

def parse_args():
    """ Load command line args """
    parser = argparse.ArgumentParser()
    parser.add_argument('--in_plink', metavar="<file>", type=str, required=True)
    parser.add_argument('--out_plink', metavar="<file>", type=str, required=True)
    parser.add_argument('--chainfile', metavar="<file>", type=str, required=True)
    args = parser.parse_args()
    return args

if __name__ == '__main__':

    main()
