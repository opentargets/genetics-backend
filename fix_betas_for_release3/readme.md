Fix betas for June 2019 release
===============================

Just before the June 2019 release, we released that a number of high profile immune related studies have the wrong alleles extracted, therefore the incorrect effect directions. These scripts fix errors in the following files:

- Top loci
- Filtered sumstats
- Credible set file
- Coloc file

Studies to flip betas for:
- GCST004131
- GCST004132
- GCST004133
- GCST001725
- GCST001728
- GCST001729
- GCST000964

```
# Start cluster
gcloud beta dataproc clusters create \
    em-cluster-fix-betas \
    --image-version=preview \
    --properties=spark:spark.debug.maxToStringFields=100,spark:spark.executor.cores=31,spark:spark.executor.instances=1 \
    --master-machine-type=n1-standard-32 \
    --master-boot-disk-size=1TB \
    --num-master-local-ssds=1 \
    --zone=europe-west1-d \
    --initialization-action-timeout=20m \
    --single-node \
    --max-idle=10m

# Submit to cluster
gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    scripts/top_loci_fix.py \
    --async
gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    scripts/credset_fix.py \
    --async
gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    scripts/coloc_fix.py \
    --async
gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    scripts/sumstats_fix.py \
    --async

# To monitor
gcloud compute ssh em-cluster-fix-betas-m \
  --project=open-targets-genetics \
  --zone=europe-west1-d -- -D 1080 -N

"EdApplications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --proxy-server="socks5://localhost:1080" \
  --user-data-dir="/tmp/em-cluster-fix-betas-m" http://em-cluster-gtex7-ingest-m:8088
```