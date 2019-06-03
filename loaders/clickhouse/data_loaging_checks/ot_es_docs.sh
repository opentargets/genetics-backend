#!/bin/bash

es_host="${ES_HOST:-localhost}"

echo genes
curl -s ${es_host}:9200/_cat/count/genes | awk '{ print $3 }'
echo studies
curl -s ${es_host}:9200/_cat/count/studies | awk '{ print $3 }'
for chr in "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "x" "y" "mt"; do
    echo ${chr} chromosome variants
	chrn=$(curl -s ${es_host}:9200/_cat/count/variant_$chr | awk '{ print $3 }')
    echo ${chrn}
    ovar=$((ovar+chrn))
done
echo overall varaints
echo ${ovar}
