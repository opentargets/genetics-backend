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
- GCST000758
- GCST000760
- GCST000755
- GCST000759

```
# Start cluster
gcloud beta dataproc clusters create \
    em-cluster-fix-betas \
    --image-version=1.4 \
    --region europe-west1 \
    --properties=spark:spark.debug.maxToStringFields=100,spark:spark.driver.memory=30g,spark:spark.executor.memory=30g,spark:spark.executor.cores=5,spark:spark.executor.instances=3 \
    --master-machine-type=n2-highmem-16 \
    --master-boot-disk-size=2TB \
    --num-master-local-ssds=0 \
    --zone=europe-west1-d \
    --initialization-action-timeout=20m \
    --single-node \
    --max-idle=10m

# Submit to cluster
gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    --region europe-west1 \
    scripts/top_loci_fix.py

gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    --region europe-west1 \
    scripts/credset_fix.py

gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    --region europe-west1 \
    scripts/coloc_fix.py

gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    --region europe-west1 \
    scripts/sumstats_fix.py

gcloud dataproc jobs submit pyspark \
    --cluster=em-cluster-fix-betas \
    --region europe-west1 \
    scripts/fine_mapping_top_loci_fix.py

# To monitor
gcloud compute ssh em-cluster-fix-betas-m \
  --project=open-targets-genetics \
  --zone=europe-west1-d -- -D 1080 -N

"EdApplications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --proxy-server="socks5://localhost:1080" \
  --user-data-dir="/tmp/em-cluster-fix-betas-m" http://em-cluster-gtex7-ingest-m:8088
```