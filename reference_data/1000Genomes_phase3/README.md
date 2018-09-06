# 1000 Genomes phase 3

Scripts to generate 1000 Genomes phase 3 plink files, split by superpopulation.


### Usage

```
# Run individually
bash 1_download_vcfs.sh
bash 2_make_population_ids.sh
bash 3_convert_to_plink.sh

# Run on cluster
bsub < master.bsub.sh
```

### Requirements

- plink v1.90b4
- bcftools
- samtools
- GNU parallel
