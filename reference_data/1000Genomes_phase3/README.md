# 1000 Genomes phase 3

Scripts to generate 1000 Genomes phase 3 plink files, split by superpopulation.

### Usage

```
export PYSPARK_SUBMIT_ARGS="--driver-memory 8g pyspark-shell"

# Run individually
bash 1_download_vcfs.sh
bash 2_normalise_vcfs.sh
bash 3_make_population_ids.sh
bash 4_convert_to_plink.sh
bash 5_liftover_to_b38.sh

# Run on cluster
bsub < master.bsub.sh
```

### Requirements

- plink v1.90b4
- bcftools
- samtools
- GNU parallel
- hail
