#!/usr/bin/env bash
#

cores=16

# Download reference genome
mkdir -p ref_grch37
cd ref_grch37
ref_name=Homo_sapiens.GRCh37.dna.toplevel.fa.bgz
if [ ! -f $ref_name ]; then
  wget ftp://ftp.ensembl.org/pub/grch37/update/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.dna.toplevel.fa.gz
  zcat < Homo_sapiens.GRCh37.dna.toplevel.fa.gz | bgzip -c > $ref_name
  samtools faidx $ref_name
fi
cd ..

# Change to vcf_norm folder
mkdir -p vcf_norm
cd vcf_norm

# Run normalisation
in_ref=../ref_grch37/$ref_name
for vcf in ../vcf/*.vcf.gz; do
  out_vcf=$(basename $vcf)
  echo "zcat < $vcf | \
  bcftools norm -Ov -m -any | \
  bcftools annotate -Ov -x ID -I +%CHROM:%POS:%REF:%ALT | \
  bcftools norm -Ov -f $in_ref | \
  bgzip -c > $out_vcf"
done | parallel -j $(($cores/2)) # Each requires 2 cores
cd ..
