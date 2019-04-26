#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#

'''
export PYSPARK_SUBMIT_ARGS = "--driver-memory 8g pyspark-shell"
'''

import hail as hl
import sys

def main():

    # # Args (local)
    # chrom = 11
    # chain_file = '/Users/em21/Projects/ot_genetics/genetics-sumstats_data/extras/prepare_uk_biobank_gwas_catalog/sitelist/input_data/grch37_to_grch38.over.chain.gz'
    # in_bgen = 'example_data/ukb_imp_chr{chrom}_v3.example.bgen'
    # in_sample = 'output/ukb_10k_downsampled.sample'
    # to_keep_list = 'output/ukb_10k_downsampled.sample_list.tsv'
    # out_plink = 'output/ukb_v3_downsampled10k_plink/ukb_v3_chr{chrom}.downsampled10k'
    # cores = 1 # Use "*" for all
    # maf_threshold = 0.001
    
    # Args (server)
    chrom = sys.argv[1]
    chain_file = '/nfs/users/nfs_e/em21/otcoregen/em21/uk_biobank_analysis/create_10k_subsample/input_data/grch37_to_grch38.over.chain.gz'
    in_bgen = '/nfs/users/nfs_e/em21/otcoregen/uk_biobank_data/data/genetics/imputation/ukb_imp_chr{chrom}_v3.bgen'
    in_sample = '/nfs/users/nfs_e/em21/otcoregen/em21/uk_biobank_analysis/create_10k_subsample/input_data/ukb_10k_downsampled.sample'
    to_keep_list = '/nfs/users/nfs_e/em21/otcoregen/em21/uk_biobank_analysis/create_10k_subsample/input_data/ukb_10k_downsampled.sample_list.tsv'
    out_plink = '/nfs/users/nfs_e/em21/otcoregen/em21/uk_biobank_analysis/create_10k_subsample/output/ukb_v3_downsampled10k_plink/ukb_v3_chr{chrom}.downsampled10k'
    cores = sys.argv[2] # Use "*" for all
    maf_threshold = 0.001

    # Set the maximum number of cores
    hl.init(master="local[{}]".format(cores))

    # Prepare liftover
    rg37 = hl.get_reference('GRCh37')
    rg38 = hl.get_reference('GRCh38')
    rg37.add_liftover(chain_file, rg38)

    # Create my own rg38 with altered names
    rg38_custom_contigs = [contig.replace('chr', '') for contig in rg38.contigs]
    rg38_custom_lens = {}
    for contig in rg38.lengths:
        rg38_custom_lens[contig.replace('chr', '')] = rg38.lengths[contig]
    rg38_custom = hl.ReferenceGenome(
        'rg38_custom', rg38_custom_contigs, rg38_custom_lens)

    print('Processing chromosome {0}'.format(chrom))

    # Index bgen if not existing
    if not hl.hadoop_exists(in_bgen.format(chrom=chrom) + '.idx2'):
        hl.index_bgen(
            in_bgen.format(chrom=chrom),
            contig_recoding={"01": "1", "02": "2", "03": "3", "04": "4",
                             "05": "5", "06": "6", "07": "7", "08": "8",
                             "09": "9"},
            reference_genome='GRCh37'
        )

    # Load bgen
    mt = hl.import_bgen(
        in_bgen.format(chrom=chrom),
        entry_fields=['GT'],
        sample_file=in_sample
    )

    # Load list samples to keep
    samples_to_keep = hl.import_table(
        to_keep_list,
        no_header=True,
        impute=False,
        types={'f0': hl.tstr}
    ).key_by('f0')

    # Downsample to required subset of samples
    mt = mt.filter_cols(hl.is_defined(samples_to_keep[mt.s]))
        
    # Re-call to remove phasing (required for plink output)
    # mt = mt.annotate_entries(GT=hl.call(mt.GT[0], mt.GT[1], phased=False))

    # Filter on MAF
    mt = hl.variant_qc(mt)
    mt = mt.annotate_rows(
        variant_qc=mt.variant_qc.annotate(MAF=hl.min(mt.variant_qc.AF))
    )
    mt = mt.filter_rows(mt.variant_qc.MAF >= maf_threshold)

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
        output=out_plink.format(chrom=chrom)
    )

    return 0

if __name__ == '__main__':

    main()
