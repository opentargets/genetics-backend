#!/bin/sh

# Change to plink folder
cd plink_format

# Process vcfs
for chrom_X in {1..22} X; do
  # Convert to plink
  for pop in EUR AFR AMR EAS SAS; do
    mkdir -p $pop; cd $pop
    IN_FILE=../vcf/ALL.chr$chrom_X.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
    OUT_FILE=1kg_p3.20130502.$pop.$chrom_X
    plink --vcf $IN_FILE --memory 8000 --keep-fam $pop.id --geno 0.05 --hwe 1e-6 --maf 0.01 --make-bed --out $OUT_FILE
    cd ..
  done
done
