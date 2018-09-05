# 1000 Genomes phase 3

Scripts to generate 1000 Genomes phase 3 plink files, split by superpopulation.


### Usage
```
bash 1_download_vcfs.sh
bash 2_make_population_ids.sh
bash 3_convert_to_plink.sh
# bsub < 3_convert_to_plink.sh
```

# Requirements

- plink v1.90b4
