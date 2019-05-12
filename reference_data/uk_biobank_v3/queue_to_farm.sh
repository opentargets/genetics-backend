#!/bin/sh
#BSUB -J ukb_downsample[1-9]
#BSUB -q basement # small=batches of 10; normal=12h max; long=48h max; basement=300 job limit; hugemem=512GB mem
#BSUB -n 8
#BSUB -R "select[mem>16000] rusage[mem=16000] span[hosts=1]" -M16000
#BSUB -o output.%J.%I
#BSUB -e errorfile.%J.%I

# Load required modules
module load hgi/systems/jdk/1.8.0_74
module load hgi/gcc/7.2.0

# Load hail env
source /nfs/users/nfs_e/em21/miniconda3/etc/profile.d/conda.sh
conda activate hail
export PYSPARK_SUBMIT_ARGS="--driver-memory 8g pyspark-shell"

# Get chromosome names from array index
chrom=$LSB_JOBINDEX
chrom_X=`echo $chrom | sed 's/23/X/'` # Convert 23 to X

# Process single chromosome
cores=8
python 4_process_bgen.py $chrom_X $cores
