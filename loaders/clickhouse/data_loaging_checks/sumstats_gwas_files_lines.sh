#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Counts lines excluding header in gwas files"
    echo "Usage: $0 google_storage_url_or_local_dir_location"
    echo "Example 1: $0 /genetics-portal-sumstats/ (note: closing slash)"
    echo "Example 2: $0 gs://genetics-portal-sumstats"
    exit 1
fi

if [[ $1 == gs:* ]]; then
   echo using Google Storage utils to read data
   cat_cmd='gsutil cat'
   list_files="gsutil ls -r $1/gwas/** "
else
   echo using local file system to read data
   cat_cmd='cat'
   list_files="find $1/gwas/** -type f "
fi

${list_files} | xargs "${cat_cmd}" | zcat | sed 1d | sed '/^\s*$/d' | wc -l
