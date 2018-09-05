#!/bin/sh
#BSUB -J vcf_to_plink[1-23]
#BSUB -q long
#BSUB -n 1
#BSUB -R "select[mem>8000] rusage[mem=8000] span[hosts=1]" -M8000
#BSUB -o output.%J.%I
#BSUB -e errorfile.%J.%I

module load hgi/plink/1.90b4

# Change to plink folder
cd plink_format

# Pad chromosome number with zeros
chrom=$LSB_JOBINDEX
chrom_X=`echo $chrom | sed 's/23/X/'` # Convert 23 to X

# Convert to plink
for pop in EUR AFR AMR EAS SAS; do
  mkdir -p $pop; cd $pop
  IN_FILE=../vcf/ALL.chr$chrom_X.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
  OUT_FILE=1kg_p3.20130502.$pop.$chrom_X
  plink --vcf $IN_FILE --memory 8000 --keep-fam $pop.id --geno 0.05 --hwe 1e-6 --maf 0.01 --make-bed --out $OUT_FILE
  cd ..
done
