#!/bin/sh

mkdir -p output/plink_format_b38
export PYSPARK_SUBMIT_ARGS="--driver-memory 64g pyspark-shell"

for chrom_X in {1..22} X Y; do
  for pop in EUR AFR AMR EAS SAS; do
    
    IN_FILE=output/plink_format_b37/$pop/$pop.$chrom_X.1000Gp3.20130502
    OUT_FILE=output/plink_format_b38/$pop/$pop.$chrom_X.1000Gp3.20130502

    # Skip completed
    if [ ! -f $OUT_FILE.bed ]; then

      # Run liftover using hail  
      python scripts/liftover_plink.py \
      --in_plink $IN_FILE \
      --out_plink $OUT_FILE \
      --chainfile grch37_to_grch38.over.chain.gz \
      --min_partitions 64

    fi

    
  done
done

gcloud compute instances stop em-liftover-1000g --zone=europe-west1-d
