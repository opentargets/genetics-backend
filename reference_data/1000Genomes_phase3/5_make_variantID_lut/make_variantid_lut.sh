#!/bin/sh
#BSUB -J make_varid_lut
#BSUB -q normal # small=batches of 10; normal=12h max; long=48h max; basement=300 job limit; hugemem=512GB mem
#BSUB -n 2
#BSUB -R "select[mem>64000] rusage[mem=64000] span[hosts=1]" -M64000
#BSUB -o output.%J
#BSUB -e errorfile.%J

# Run interactive:   bsub -q normal -J interactive -n 2 -R "select[mem>32000] rusage[mem=32000] span[hosts=1]" -M32000 -Is bash

set -euo pipefail

# Get 1000 Genomes bims as input
mkdir -p input/bims
cd input/bims
gsutil -m cp -n "gs://genetics-portal-raw/1000Genomes_phase3/plink_format/*/*.*.1000Gp3.20130502.bim" .
cd ../..

# Get the 1000 Genomes  ensembl variation VCF as input
mkdir -p input/vcf
cd input/vcf
vcf_name=Homo_sapiens.GRCh37.1000G.vcf.gz
if [ ! -f $vcf_name ]; then
  wget -O - ftp://ftp.ensembl.org/pub/grch37/update/variation/vcf/homo_sapiens/Homo_sapiens.vcf.gz | zgrep E_1000G | gzip -c > $vcf_name
fi
cd ../..

# Make the LUT
mkdir -p output
out_name=output/variantID_to_1000Gp3_lut.tsv.gz
python scripts/make_1000g_rsid_lut.py \
  --bims input/bims/*.bim \
  --vcf input/vcf/$vcf_name \
  --outf $out_name

echo COMPLETE
