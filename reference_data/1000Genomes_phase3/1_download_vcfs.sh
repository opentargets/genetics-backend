#!/usr/bin/env bash
#

# Args
FTP_SITE=ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502

# Change to vcf folder
mkdir -p output/vcf
cd output/vcf

# Get panel info
wget $FTP_SITE/integrated_call_samples_v3.20130502.ALL.panel

# Get autosomes
for CHR in `seq 1 22`; do
   FILE=$FTP_SITE/ALL.chr$CHR.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
   outname=$CHR.1000Gp3.vcf.gz
   wget -O $outname $FILE
   wget -O $outname.tbi $FILE.tbi
   sleep 2
done

# Get X and rename for convenience
FILE=$FTP_SITE/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz
outname=X.1000Gp3.vcf.gz
wget -O $outname $FILE
wget -O $outname.tbi $FILE.tbi
sleep 2

cd ../..

# Get Y and rename for convenience
# FILE=$FTP_SITE/ALL.chrY.phase3_integrated_v2a.20130502.genotypes.vcf.gz
# outname=Y.1000Gp3.vcf.gz
# wget -O $outname $FILE
# wget -O $outname.tbi $FILE.tbi
