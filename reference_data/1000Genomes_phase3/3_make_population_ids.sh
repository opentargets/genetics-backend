# Change to plink folder
mkdir -p output/plink_format
cd output/plink_format

# Get super population IDs
for pop in AFR AMR EAS EUR SAS; do
  grep -w $pop ../vcf/integrated_call_samples_v3.20130502.ALL.panel | cut -f1 > $pop.id
done
cd ../..
