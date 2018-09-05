# 1000 Genomes phase 3

Scripts to generate 1000 Genomes phase 3 plink files, split by superpopulation.


### Usage

`3_convert_to_plink.bsub.sh` is written to be run on a cluster using `bsub`. It gets chromosome names from the array index. `3_convert_to_plink.sh` should work locally but is untested.

```
bash 1_download_vcfs.sh
bash 2_make_population_ids.sh
bsub < 3_convert_to_plink.bsub.sh
# bash 3_convert_to_plink.sh
```

### Requirements

- plink v1.90b4
