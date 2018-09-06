#!/bin/sh

cores=8

cd output/plink_format

# Process vcfs
for chrom_X in {1..22} X Y; do
  # Convert to plink
  for pop in EUR AFR AMR EAS SAS; do
    mkdir -p $pop
    IN_FILE=../vcf_norm/$chrom_X.1000Gp3.vcf.gz
    OUT_FILE=$pop/$pop.$chrom_X.1000Gp3.20130502
    echo plink --vcf $IN_FILE \
      --memory 8000 \
      --keep-fam $pop.id \
      --geno 0.05 \
      --hwe 1e-6 \
      --maf 0.005 \
      --make-bed \
      --keep-allele-order \
      --vcf-idspace-to _ \
      --out $OUT_FILE
  done
done | parallel -j $cores
cd ../..
