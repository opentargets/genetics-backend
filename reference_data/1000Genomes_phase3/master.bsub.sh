#!/bin/sh
#BSUB -J vcf_to_plink
#BSUB -q long
#BSUB -n 8
#BSUB -R "select[mem>64000] rusage[mem=64000] span[hosts=1]" -M64000
#BSUB -o output.%J
#BSUB -e errorfile.%J

set -euo pipefail

# Load modules
module load hgi/plink/1.90b4
module load hgi/samtools/1.6-htslib-1.6-htslib-plugins-6f2229e0-irods-git-4.2.2-plugin_kerberos-2.0.0-ncurses-6.0
module load hgi/bcftools/1.6-htslib-1.6-htslib-plugins-6f2229e0-irods-git-4.2.2-plugin_kerberos-2.0.0
export PYSPARK_SUBMIT_ARGS="--driver-memory 8g pyspark-shell"


# Run commands
bash 1_download_vcfs.sh
bash 2_normalise_vcfs.sh
bash 3_make_population_ids.sh
bash 4_convert_to_plink.sh
bash 5_liftover_to_b38.sh

echo COMPLETE
