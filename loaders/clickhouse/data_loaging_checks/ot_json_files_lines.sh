#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Counts number of lines in input json files"
    echo "Usage: $0 google_storage_url_or_local_dir_location"
    echo "Example 1: $0 /home/user/open-targets-genetics-releases/19.03.03"
    echo "Example 2: $0 gs://open-targets-genetics-releases/19.03.03"
    exit 1
fi

if [[ $2 == gs:* ]]; then
   cat_cmd="gsutil cat"
else
   cat_cmd="cat"
fi

base_path=${1}

echo genes
"${cat_cmd}" ${base_path}/lut/genes-index/part-* | wc -l
echo studies
"${cat_cmd}" ${base_path}/lut/study-index/part-* | wc -l
echo overlaps
"${cat_cmd}" ${base_path}/lut/overlap-index/part-* | wc -l
echo varaints
"${cat_cmd}" ${base_path}/lut/variant-index/part-* | wc -l
echo d2v2g
"${cat_cmd}" ${base_path}/d2v2g/part-* | wc -l
echo v2d
"${cat_cmd}" ${base_path}/v2d/part-* | wc -l
echo v2g
"${cat_cmd}" ${base_path}/v2g/part-* | wc -l
